local find_project_root = require("utils.paths").find_project_root

-- Sadly, I needed to copy - paste this into javaServer.lua
local root_dir, single_file = find_project_root({
	".git",
	"mvnw",
	"gradlew"
})
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

-- Helper function for highlighting semantic_tokens
local function set_highlight(token, args, highlight_group)
	vim.lsp.semantic_tokens.highlight_token(
		token, args.buf, args.data.client_id, highlight_group
	)
end

local custom_static_non_final = "StaticNonFinal"
vim.cmd.highlight(custom_static_non_final, "guifg=#f7768e")

vim.api.nvim_create_autocmd('LspTokenUpdate', {
	buffer = 0,
	callback = function(args)
		local token = args.data.token

		if token.type == "namespace" and token.modifiers.importDeclaration then
			set_highlight(token, args, "@variable")
		end

		if token.type ~= "property" then
			return
		end

		-- Readonly means "final" in java
		if token.modifiers.readonly then
			set_highlight(token, args, "Constant")

		else
			if token.modifiers.static then
				set_highlight(token, args, custom_static_non_final)
			else
				set_highlight(token, args, "@property")
			end
		end
	end,
})

require("lsp.serverCommon").start_or_attach(
	"javaServer",
	root_dir,
	single_file
)

local run_command
if single_file then
	local full_fname = vim.fn.expand("%:p")
	local build_cmd = 'javac "' .. full_fname .. '"'
	local class_name = vim.fn.expand("%:p:t:r")
	run_command = build_cmd
		.. ' && java -cp "'
		.. root_dir
		.. '" '
		.. class_name
else
	run_command = "gradle build"
end

vim.b.run_command = run_command

-- Use 4 spaces instead of tabs (Java Checkstyle linter prefers spaces)
vim.bo[0].tabstop = 4
vim.bo[0].shiftwidth = 4
vim.bo[0].expandtab = true
