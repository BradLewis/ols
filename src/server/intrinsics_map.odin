#+feature dynamic-literals
// Generated via `./tools/generators/intrinsics_map.odin` - do not edit
package server

intrinsic_proc_map: map[string]proc(_: Symbol) -> bool = {
	"type_is_boolean"    = type_is_boolean,
	"type_is_integer"    = type_is_integer,
	"type_is_rune"       = type_is_rune,
	"type_is_float"      = type_is_float,
	"type_is_complex"    = type_is_complex,
	"type_is_quaternion" = type_is_quaternion,
	"type_is_any"        = type_is_any,
	"type_is_string"     = type_is_string,
	"type_is_string16"   = type_is_string16,
	"type_is_cstring"    = type_is_cstring,
	"type_is_cstring16"  = type_is_cstring16,
	"type_is_numeric"    = type_is_numeric,
	"type_is_array"      = type_is_array,
}
