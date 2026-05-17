package main

import "src:odin/format"
import "core:strings"
import "core:fmt"
import "core:os"
import "core:odin/ast"
import "core:odin/parser"

main :: proc() {
	fullpath := "./src/server/intrinsics.odin"
	data, in_err := os.read_entire_file(fullpath, context.allocator)
	if in_err != nil {
		fmt.fprintfln(os.stderr, "failed to read file '%s': %v", fullpath, in_err)
		os.exit(1)
	}
	output_path := "./src/server/intrinsics_map.odin"

	pkg := ast.Package {
		kind = .Normal,
	}
	file := ast.File {
		pkg      = &pkg,
		src      = string(data),
		fullpath = fullpath,
	}
	p := parser.default_parser()

	ok := parser.parse_file(&p, &file)
	if !ok {
		fmt.fprintfln(os.stderr, "failed to parse file '%s'", fullpath)
		os.exit(1)
	}

	proc_names: [dynamic]string

	for stmt in file.decls {
		if value_decl, ok := stmt.derived.(^ast.Value_Decl); ok {
			for name in value_decl.names {
				if ident, ok := name.derived.(^ast.Ident); ok {
					if strings.starts_with(ident.name, "type") {
						append(&proc_names, ident.name)
					}
				}
			}
		}
	}

	sb: strings.Builder
	strings.write_string(&sb, "#+feature dynamic-literals\n")
	strings.write_string(&sb, "// Generated via `./tools/generators/intrinsics_map.odin` - do not edit\n")
	strings.write_string(&sb, "package server\n\n")
	strings.write_string(&sb, "intrinsic_proc_map: map[string]proc(_: Symbol) -> bool = {\n")
	for p in proc_names {
		fmt.sbprintfln(&sb, `"%s" = %s,`, p, p)
	}
	strings.write_string(&sb, "}")
	s := strings.to_string(sb)

	if formatted, ok := format.format(output_path, s, format.find_config_file_or_default(".")); ok {
		if err := os.write_entire_file(output_path, formatted); err != nil {
			fmt.fprintfln(os.stderr, "failed to write output to '%s': %v", output_path, err)
			os.exit(1)
		}
		fmt.printfln("Successfully generated file to '%s'", output_path)
		os.exit(0)
	}

	fmt.fprintln(os.stderr, "failed to format output")
	os.exit(1)
}
