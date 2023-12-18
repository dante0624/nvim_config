local paths = require("utils.paths")

local pattern = '.*: line (%d+), col (%d+), (%a+) %- (.+) %((.+)%)'
local groups = { 'lnum', 'col', 'severity', 'message', 'code' }
local severities = {
	error = vim.diagnostic.severity.INFO,
	warning = vim.diagnostic.severity.HINT,
}

local linter_name = "htmlhint"

return {
	cmd = paths.Mason_Bin .. linter_name,
	stdin = true,
	args = {
		"stdin",
		"-f",
		"compact",
		"--rules",

		-- Doctype and head rules
		"doctype-first,title-require,html-lang-require," ..

		-- Attributes
		"attr-lowercase,attr-no-duplication,attr-no-unnecessary-whitespace," ..
		"attr-unsafe-chars,attr-value-double-quotes,attr-value-not-empty," ..
		"attr-sorted,alt-require,input-requires-label," ..

		--Tags
		"tag-pair,tag-self-close,tagname-lowercase,tagname-specialchars," ..
		"src-not-empty," ..

		--ID
		"id-class-ad-disabled,id-class-value=dash,id-unique," ..

		-- Formatting
		"space-tab-mixed-disabled,spec-char-escape"
	},
	stream = "stdout",
	ignore_exitcode = true,
	parser = require('lint.parser').from_pattern(
		pattern,
		groups,
		severities,
		{ source = linter_name }
	)
}
