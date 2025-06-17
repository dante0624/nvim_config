local map = require("utils.map").map
local dap_utils = require("utils.dapUtils")
local java_utils = require("utils.javaUtils")

-- Begin this file with some low-hanging fruit
-- Setup auto-commands and buffer-local preferences
-- These work the same for either source java files or class files
local folding = require("core.myModules.folding")
folding.setup_treesitter_folding()

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

-- Now, worry about starting-up or attaching to a JDTLS instance
-- Also worry about de-compiling class files
local jdtls_root_dir, single_file = java_utils.get_jdtls_root_dir()
local bufnr = vim.api.nvim_get_current_buf()
local bufname = vim.api.nvim_buf_get_name(bufnr)

-- Made-up jdt URI
local is_jdt_uri_class_file = vim.startswith(bufname, "jdt://")
-- Normal file path on the filesystem, ending with .class
local is_normal_class_file = vim.endswith(bufname, ".class") and
	not is_jdt_uri_class_file

local function jdtls_start_or_attach()
	return require("lsp.serverCommon").start_or_attach(
		java_utils.server_config_name,
		jdtls_root_dir,
		single_file
	)
end


local function decompile(jdtls_client)
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].buftype = 'nofile'
	vim.bo[bufnr].buflisted = true

	local content
	local function handler(_, result)
		content = result
		local normalized = string.gsub(result, '\r\n', '\n')
		local source_lines = vim.split(normalized, "\n", { plain = true })
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, source_lines)
	end

	if (is_jdt_uri_class_file) then
		local params = { uri = bufname }
		-- Custom extention of the Language Server Protocol
		-- https://github.com/eclipse-jdtls/eclipse.jdt.ls/wiki/Language-Server-Protocol-Extensions
		jdtls_client:request("java/classFileContents", params, handler, bufnr)
	elseif (is_normal_class_file) then
		local cmd = {
		  command = "java.decompile",
		  arguments = { vim.uri_from_bufnr(bufnr) }
		}
		jdtls_client:request('workspace/executeCommand', cmd, handler, bufnr)
	else
		print("Illegal state in java.lua, decompile() function")
		return
	end

	-- Need to block. Otherwise logic could run that sets the cursor
	-- to a position that's still missing.
	vim.wait(5000, function() return content ~= nil end)

	vim.bo[bufnr].modifiable = false
end

if (is_jdt_uri_class_file or is_normal_class_file) then
	local active_jdtls_client = java_utils.get_chosen_lsp_client()
	if (active_jdtls_client == nil) then
		if (is_jdt_uri_class_file)  then
			print("Error: trying to open a jdt:// URI but no jdtls clients")
			return
		end

		-- Opening a .class file before any .java file is valid
		-- Will start new jdtls client, attach, and use to decompile
		local client_id = jdtls_start_or_attach()
		local new_jdtls_client = vim.lsp.get_client_by_id(client_id)
		decompile(new_jdtls_client)
	else
		decompile(active_jdtls_client)
		vim.lsp.buf_attach_client(bufnr, active_jdtls_client.id)
	end

-- Handle normal .java files
else
	jdtls_start_or_attach()
end


local full_file_path = vim.fn.expand("%:p")
local class_name = vim.fn.expand("%:p:t:r")
local run_command

if single_file then
	local build_cmd = 'javac "' .. full_file_path .. '"'
	run_command = build_cmd
		.. ' && java -cp "'
		.. jdtls_root_dir
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
	local path_to_gradle_root = jdtls_root_dir
	local path_to_html_ut_results = path_to_gradle_root .. "build/reports/tests/test/index.html"

	run_command = '( cd "' .. path_to_gradle_root .. '" ; ' ..
		run_unit_test_cmd .. " ; " ..
		'echo "Unit Test Results are available at: ' .. path_to_html_ut_results .. '" )'
end

-- TODO: Re-write me to allow for a function rather than a static string
-- This will allow for testing a single UT
vim.b.run_command = run_command

local function custom_run()
	local dap = require("dap")
	if dap.session() ~= nil then
		dap.continue()
	else
		java_utils.start_debug()
	end
end



-- TODO: Move most of these to a common place
-- Just make custom_run be a local_mapping
map("", "<leader>dr", custom_run)
map("", "<leader>dt", dap_utils.terminate_and_cleanup)

map("", "<leader>db", function() require("dap").toggle_breakpoint() end)
map("", "<leader>dg", function()
	require("dap").list_breakpoints()
	vim.cmd("copen")
end)
map("", "<leader>dn", function() require("dap").clear_breakpoints() end)

map("", "<leader>dj", function() require("dap").step_over() end)
map("", "<leader>dk", function() require("dap").step_back() end)
map("", "<leader>dh", function() require("dap").step_out() end)
map("", "<leader>dl", function() require("dap").step_into() end)

map("", "<leader>df", function() require("dap").focus_frame() end)
map("", "<leader>da", function() require("dap").run_to_cursor() end)

-- v for "variables in scope"
map("", "<leader>dv", function()
	dap_utils.open_or_create_widget("sidebar", "scopes", "40 vsplit")
end)
-- s for "stacktrace"
map("", "<leader>ds", function()
	dap_utils.open_or_create_widget("sidebar", "frames", "15 split")
end)
-- m for "multi-threading"
map("", "<leader>dm", function()
	dap_utils.open_or_create_widget("sidebar", "threads", "15 split")
end)

-- TODO: Figure out why this isn't working
-- c for "console (interactive)"
map("", "<leader>dc", function()
	local _, win_id = require("dap").repl.open()
	vim.api.nvim_set_current_win(win_id)
end)

