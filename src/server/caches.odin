package server

import "src:common"

import "core:mem/virtual"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:time"

//Used in semantic tokens and inlay hints to handle the entire file being resolved.

FileResolve :: struct {
	symbols: map[uintptr]SymbolAndNode,
}


FileResolveCache :: struct {
	files: map[string]FileResolve,
}

@(thread_local)
file_resolve_cache: FileResolveCache

resolve_entire_file_cached :: proc(document: ^Document, index: ^Indexer) -> FileResolve {

	file, cached := file_resolve_cache.files[document.uri.uri]

	if !cached {
		file = {
			symbols = resolve_entire_file(document, index, .None, virtual.arena_allocator(document.allocator)),
		}
		file_resolve_cache.files[document.uri.uri] = file
	}

	return file
}

resolve_ranged_file_cached :: proc(
	document: ^Document,
	index: ^Indexer,
	range: common.Range,
	allocator := context.allocator,
) -> FileResolve {

	file, cached := file_resolve_cache.files[document.uri.uri]

	if !cached {
		file = {
			symbols = resolve_ranged_file(document, range, index, allocator),
		}
	}

	return file
}

BuildCache :: struct {
	loaded_pkgs: map[string]PackageCacheInfo,
	pkg_aliases: map[string][dynamic]string,
}

PackageCacheInfo :: struct {
	timestamp: time.Time,
}

clear_all_package_aliases :: proc(index: ^Indexer) {
	for collection_name, alias_array in index.cache.pkg_aliases {
		for alias in alias_array {
			delete(alias)
		}
		delete(alias_array)
	}

	clear(&index.cache.pkg_aliases)
}

//Go through all the collections to find all the possible packages that exists
find_all_package_aliases :: proc(index: ^Indexer) {
	for k, v in common.config.collections {
		pkgs := make([dynamic]string, context.temp_allocator)
		append_packages(v, &pkgs, {}, context.temp_allocator)

		for pkg in pkgs {
			if pkg, err := filepath.rel(v, pkg, context.temp_allocator); err == .None {
				forward_pkg, _ := filepath.replace_path_separators(pkg, '/', context.temp_allocator)
				if k not_in index.cache.pkg_aliases {
					index.cache.pkg_aliases[k] = make([dynamic]string)
				}

				aliases := &index.cache.pkg_aliases[k]

				append(aliases, strings.clone(forward_pkg))
			}
		}
	}
}
