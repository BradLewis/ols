package server

import "core:strings"
import "src:common"

Indexer :: struct {
	builtin_packages: [dynamic]string,
	runtime_package:  string,
	index:            MemoryIndex,
	cache:            BuildCache,
	entrypoint_pkgs:  map[string][dynamic]string,
}

FuzzyResult :: struct {
	symbol: Symbol,
	score:  f32,
}

setup_index :: proc(index: ^Indexer, builtin_path: string, config: ^common.Config, allocator := context.allocator) {
	index.cache.loaded_pkgs = make(map[string]PackageCacheInfo, 50, allocator)
	symbol_collection := make_symbol_collection(allocator, config)
	index.index = make_memory_index(symbol_collection)
	index.entrypoint_pkgs = make(map[string][dynamic]string, allocator)

	try_build_package(index, builtin_path)
}

clear_index_cache :: proc(indexer: ^Indexer) {
	memory_index_clear_cache(&indexer.index)
}

should_skip_private_symbol :: proc(symbol: Symbol, current_pkg, current_file: string) -> bool {
	if .PrivateFile not_in symbol.flags && .PrivatePackage not_in symbol.flags {
		return false
	}

	if current_file == "" {
		return false
	}

	symbol_file := strings.trim_prefix(symbol.uri, "file://")
	current_file := strings.trim_prefix(current_file, "file://")
	if .PrivateFile in symbol.flags && symbol_file != current_file {
		return true
	}

	if .PrivatePackage in symbol.flags && current_pkg != symbol.pkg {
		return true
	}
	return false
}

is_builtin_pkg :: proc(pkg: string) -> bool {
	return strings.equal_fold(pkg, "$builtin") || strings.has_suffix(pkg, "/builtin")
}

lookup_builtin_symbol :: proc(index: ^Indexer, name: string, current_file: string) -> (Symbol, bool) {
	if symbol, ok := lookup_symbol(index, name, "$builtin", current_file); ok {
		return symbol, true
	}

	for built in index.builtin_packages {
		if symbol, ok := lookup_symbol(index, name, built, current_file); ok {
			return symbol, true
		}
	}

	return {}, false
}

lookup :: proc(
	index: ^Indexer,
	name: string,
	pkg: string,
	current_file: string,
	loc := #caller_location,
) -> (
	Symbol,
	bool,
) {
	if name == "" {
		return {}, false
	}

	if is_builtin_pkg(pkg) {
		return lookup_builtin_symbol(index, name, current_file)
	}

	return lookup_symbol(index, name, pkg, current_file)
}

@(private = "file")
lookup_symbol :: proc(index: ^Indexer, name: string, pkg: string, current_file: string) -> (Symbol, bool) {
	if symbol, ok := memory_index_lookup(&index.index, name, pkg); ok {
		current_pkg := get_package_from_filepath(current_file)
		if should_skip_private_symbol(symbol, current_pkg, current_file) {
			return {}, false
		}
		return symbol, true
	}

	return {}, false
}

fuzzy_search :: proc(
	index: ^Indexer,
	name: string,
	pkgs: []string,
	current_file: string,
	resolve_fields := false,
	limit := 0,
) -> (
	[]FuzzyResult,
	bool,
) {
	results, ok := memory_index_fuzzy_search(&index.index, name, pkgs, current_file, resolve_fields, limit = limit)
	if !ok {
		return {}, false
	}
	return results[:], true
}
