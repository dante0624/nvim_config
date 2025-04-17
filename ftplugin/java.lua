local find_project_root = require("utils.paths").find_project_root

-- Sadly, I needed to copy - paste this into javaServer.lua
local root_dir, single_file = find_project_root({
	".git",
	"mvnw",
	"gradlew"
})

local folding = require("core.myModules.folding")

folding.setup_syntax_folding()

-- Use 4 spaces instead of tabs (Java Checkstyle linter prefers spaces)
vim.bo[0].tabstop = 4
vim.bo[0].shiftwidth = 4
vim.bo[0].expandtab = true

-- Helper function for highlighting semantic_tokens
local function set_highlight(token, args, highlight_group)
	vim.lsp.semantic_tokens.highlight_token(
		token, args.buf, args.data.client_id, highlight_group
	)
end

local custom_static_non_final = "StaticNonFinal"
vim.cmd.highlight(custom_static_non_final, "guifg=#f7768e")

local custom_non_static_non_final = "NonStaticNonFinal"
vim.cmd.highlight(custom_non_static_non_final, "guifg=#1abc9c")

vim.api.nvim_create_autocmd('LspTokenUpdate', {
	buffer = 0,
	callback = function(args)
		local token = args.data.token

		if token.type == "namespace" and token.modifiers.importDeclaration then
			set_highlight(token, args, "@variable")
			return
		end

		if token.type ~= "property" then
			return
		end

		local final = token.modifiers.readonly
		local static = token.modifiers.static

		if static then
			if final then
				set_highlight(token, args, "Constant")
			else
				set_highlight(token, args, custom_static_non_final)
			end

		else
			if final then
				set_highlight(token, args, custom_non_static_non_final)
			else
				set_highlight(token, args, "@property")
			end
		end
	end,
})

local bufnr = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  -- Won't be able to get the correct root path for decompiled java classes
  -- So need to connect to an existing client
  -- Connect it to the client which made the textDocument/definition request
  if vim.startswith(bufname, 'jdt://') then
	local client_id = vim.fn.getbufvar(bufnr, "java_decomp_client_id")
	vim.lsp.buf_attach_client(bufnr, client_id)

	-- Return early from this. Everything else is for source java files
	return
  end


require("lsp.serverCommon").start_or_attach(
	"javaServer",
	root_dir,
	single_file
)

local full_file_path = vim.fn.expand("%:p")
local class_name = vim.fn.expand("%:p:t:r")
local run_command

if single_file then
	local build_cmd = 'javac "' .. full_file_path .. '"'
	run_command = build_cmd
		.. ' && java -cp "'
		.. root_dir
		.. '" '
		.. class_name
else
	-- Will include the full package and the class name. For example:
	-- com.fasterxml.jackson.databind.ObjectMapper
	local full_class_path = ""
	local start_of_java_package = false
	for dir_name in string.gmatch(full_file_path, '([^//]+)') do
		if start_of_java_package and not vim.endswith(dir_name, ".java") then
			full_class_path = full_class_path .. dir_name .. "."
		end
		if dir_name == "java" then
			start_of_java_package = true
		end
	end
	full_class_path = full_class_path .. class_name

	local run_unit_test_cmd = 'gradle test --tests "' .. full_class_path .. '" --rerun-tasks'
	local path_to_gradle_root = root_dir
	local path_to_html_ut_results = path_to_gradle_root .. "build/reports/tests/test/index.html"

	run_command = '( cd "' .. path_to_gradle_root .. '" ; ' ..
		run_unit_test_cmd .. " ; " ..
		'echo "Unit Test Results are available at: ' .. path_to_html_ut_results .. '" )'
end

vim.b.run_command = run_command

