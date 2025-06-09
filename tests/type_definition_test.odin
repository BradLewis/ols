package tests 

import "core:testing"

import "src:common"

import test "src:testing"

@(test)
ast_goto_struct_definition ::proc(t: ^testing.T) {
	source := test.Source{
		main = `package test
		Bar :: struct {
			bar: int,
		}

		main :: proc() {
			b{*}ar := Bar{}
		}
		`,
	}

	location := common.Location {
		range = {
			start = {line = 1, character = 9},
			end = {line = 3, character = 3},
		},
	}

	test.expect_type_definition_locations(t, &source, {location})
}

@(test)
ast_goto_struct_field_definition ::proc(t: ^testing.T) {
	source := test.Source{
		main = `package test
		Foo :: struct {
			foo: string,
		}
		Bar :: struct {
			bar: Foo,
		}

		main :: proc() {
			bar := Bar{
				ba{*}r = Foo{},
			}
		}
		`,
	}

	location := common.Location {
		range = {
			start = {line = 1, character = 9},
			end = {line = 3, character = 3},
		},
	}

	test.expect_type_definition_locations(t, &source, {location})
}

@(test)
ast_goto_struct_field_definition_from_use ::proc(t: ^testing.T) {
	source := test.Source{
		main = `package test
		Foo :: struct {
			foo: string,
		}

		Bar :: struct {
			bar: Foo,
		}

		main :: proc() {
			bar := Bar{}
			bar.ba{*}r = "Test"
		}
		`,
	}

	location := common.Location {
		range = {
			start = {line = 1, character = 9},
			end = {line = 3, character = 3},
		},
	}

	test.expect_type_definition_locations(t, &source, {location})
}

@(test)
ast_goto_procedure_return ::proc(t: ^testing.T) {
	source := test.Source{
		main = `package test
		Foo :: struct {
			foo: string,
		}

		bar :: proc() -> Foo {
			return Foo{}
		}

		main :: proc() {
			f{*}oo := bar()
		}
		`,
	}

	location := common.Location {
		range = {
			start = {line = 1, character = 9},
			end = {line = 3, character = 3},
		},
	}

	test.expect_type_definition_locations(t, &source, {location})
}
