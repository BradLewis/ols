package server

import "core:fmt"
import "core:hash"
import "core:log"
import "core:slice"
import "core:strings"

import "src:common"

MemoryIndex :: struct {
	collection:        SymbolCollection,
	last_package_name: string,
	last_package:      ^map[string]Symbol,
}

make_memory_index :: proc(collection: SymbolCollection) -> MemoryIndex {
	return MemoryIndex{collection = collection}
}

memory_index_clear_cache :: proc(index: ^MemoryIndex) {
	index.last_package_name = ""
	index.last_package = nil
}

memory_index_lookup :: proc(index: ^MemoryIndex, name: string, pkg: string) -> (symbol: Symbol, ok: bool) {
	file_uri := index.collection.packages[pkg] or_return
	node_uri := file_uri[name] or_return
	symbol_file := index.collection.files[node_uri] or_return
	return symbol_file.symbols[name]
}

memory_index_fuzzy_search :: proc(index: ^MemoryIndex, name: string, pkgs: []string) -> ([]FuzzyResult, bool) {
	symbols := make([dynamic]FuzzyResult, 0, context.temp_allocator)

	fuzzy_matcher := common.make_fuzzy_matcher(name)

	top := 100

	for pkg in pkgs {
		if pkg, ok := index.collection.files[pkg]; ok {
			for _, symbol in pkg.symbols {
				if score, ok := common.fuzzy_match(fuzzy_matcher, symbol.name); ok == 1 {
					result := FuzzyResult {
						symbol = symbol,
						score  = score,
					}

					append(&symbols, result)
				}
			}
		}
	}

	slice.sort_by(symbols[:], proc(i, j: FuzzyResult) -> bool {
		return j.score < i.score
	})

	if name == "" {
		return symbols[:], true
	} else {
		return symbols[:min(top, len(symbols))], true
	}
}
