package server

import "core:strings"

import "src:common"

CodeActionKind :: string

CodeActionClientCapabilities :: struct {
	codeActionLiteralSupport: struct {
		codeActionKind: struct {
			valueSet: [dynamic]CodeActionKind,
		},
	},
}

CodeActionOptions :: struct {
	codeActionKinds: []CodeActionKind,
	resolveProvider: bool,
}

CodeActionParams :: struct {
	textDocument: TextDocumentIdentifier,
	range: common.Range,
}

CodeAction :: struct {
	title: string,
	kind: CodeActionKind,
	isPreferred: bool,
	edit: WorkspaceEdit,
}

get_code_actions :: proc(document: ^Document, range: common.Range) -> ([]CodeAction, bool) {
	edit: TextEdit = {
		range = range,
		newText = "hello!"
	}
	changes := make(map[string][dynamic]TextEdit, 0, context.temp_allocator)
	changes[strings.clone(document.uri.uri, context.temp_allocator)] = make([dynamic]TextEdit, context.temp_allocator)
	append(&changes[document.uri.uri], edit)
	workspace: WorkspaceEdit

	workspace.changes = make(map[string][]TextEdit, len(changes), context.temp_allocator)

	for k, v in changes {
		workspace.changes[k] = v[:]
	}
	actions: []CodeAction = {
		{title = "Do nothing", kind = "refactor.rewrite", isPreferred = true, edit = workspace },
	}
	return actions, true
}
