#+feature dynamic-literals
package server

type_is_boolean :: proc(s: Symbol) -> bool {
	return check_basic_types(s, .Bool)
}

type_is_integer :: proc(s: Symbol) -> bool {
	return check_basic_types(s, .Integer)
}

type_is_rune :: proc(s: Symbol) -> bool {
	return check_symbol_basic_name(s, "rune")
}

type_is_float :: proc(s: Symbol) -> bool {
	return check_basic_types(s, .Float)
}

type_is_complex :: proc(s: Symbol) -> bool {
	return check_basic_types(s, .Complex)
}

type_is_quaternion :: proc(s: Symbol) -> bool {
	return check_basic_types(s, .Quaternion)
}

// type_is_typeid :: proc(s: Symbol) -> bool {}


type_is_any :: proc(s: Symbol) -> bool {
	return check_symbol_basic_name(s, "any")
}

type_is_string :: proc(s: Symbol) -> bool {
	return check_symbol_basic_name(s, "string")
}

type_is_string16 :: proc(s: Symbol) -> bool {
	return check_symbol_basic_name(s, "string16")
}

type_is_cstring :: proc(s: Symbol) -> bool {
	return check_symbol_basic_name(s, "cstring")
}

type_is_cstring16 :: proc(s: Symbol) -> bool {
	return check_symbol_basic_name(s, "cstring16")
}

// type_is_endian_platform       :: proc(s: Symbol) -> bool {}
// type_is_endian_little         :: proc(s: Symbol) -> bool {}
// type_is_endian_big            :: proc(s: Symbol) -> bool {}
// type_is_unsigned              :: proc(s: Symbol) -> bool {}


type_is_numeric :: proc(s: Symbol) -> bool {
	return check_basic_types(s, .Integer, .Float, .Complex, .Quaternion)
}

// type_is_ordered               :: proc(s: Symbol) -> bool {}
// type_is_ordered_numeric       :: proc(s: Symbol) -> bool {}
// type_is_indexable             :: proc(s: Symbol) -> bool {}
// type_is_sliceable             :: proc(s: Symbol) -> bool {}
// type_is_comparable            :: proc(s: Symbol) -> bool {}
// type_is_simple_compare        :: proc(s: Symbol) -> bool {}
// type_is_nearly_simple_compare :: proc(s: Symbol) -> bool {}
// type_is_dereferenceable       :: proc(s: Symbol) -> bool {}
// type_is_valid_map_key         :: proc(s: Symbol) -> bool {}
// type_is_valid_matrix_elements :: proc(s: Symbol) -> bool {}

// type_is_named            :: proc(s: Symbol) -> bool {}
// type_is_pointer          :: proc(s: Symbol) -> bool {}
// type_is_multi_pointer    :: proc(s: Symbol) -> bool {}


type_is_array :: proc(s: Symbol) -> bool {
	if _, ok := s.value.(SymbolFixedArrayValue); ok {
		return true
	}
	return false
}

// type_is_enumerated_array :: proc(s: Symbol) -> bool {}
// type_is_slice            :: proc(s: Symbol) -> bool {}
// type_is_dynamic_array    :: proc(s: Symbol) -> bool {}
// type_is_map              :: proc(s: Symbol) -> bool {}
// type_is_struct           :: proc(s: Symbol) -> bool {}
// type_is_union            :: proc(s: Symbol) -> bool {}
// type_is_enum             :: proc(s: Symbol) -> bool {}
// type_is_proc             :: proc(s: Symbol) -> bool {}
// type_is_bit_set          :: proc(s: Symbol) -> bool {}
// type_is_bit_field        :: proc(s: Symbol) -> bool {}
// type_is_simd_vector      :: proc(s: Symbol) -> bool {}
// type_is_matrix           :: proc(s: Symbol) -> bool {}


check_basic_types :: proc(s: Symbol, types: ..SymbolUntypedValueType) -> bool {
	if basic, ok := s.value.(SymbolBasicValue); ok {
		for t in types {
			options := untyped_map[t]
			for o in options {
				if basic.ident.name == o {
					return true
				}
			}
		}
	}
	return false
}


check_symbol_basic_name :: proc(s: Symbol, name: string) -> bool {
	if basic, ok := s.value.(SymbolBasicValue); ok {
		if basic.ident.name == name {
			return true
		}
	}
	return false
}
