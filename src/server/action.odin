package server

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
	//edit: TextEdit = {
	//	range = range,
	//	newText = "hello!"
	//}
	actions: []CodeAction = {
		{title = "Do nothing", kind = "refactor.rewrite", isPreferred = true, edit = {} },
		{title = "Do another nothing", kind = "refactor.rewrite", isPreferred = false},
	}
	w: WorkspaceEdit = {
		changes = {}
	}
	return actions, true

	//return {}, false
}
