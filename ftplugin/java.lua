local find_project_root = require("utils.paths").find_project_root

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
local server_config_name = "javaServer"
local root_dir, single_file = find_project_root({
	".git",
	"mvnw",
	"gradlew"
})
local bufnr = vim.api.nvim_get_current_buf()
local bufname = vim.api.nvim_buf_get_name(bufnr)

-- Made-up jdt URI
local is_jdt_uri_class_file = vim.startswith(bufname, "jdt://")
-- Normal file path on the filesystem, ending with .class
local is_normal_class_file = vim.endswith(bufname, ".class") and
	not is_jdt_uri_class_file

local function jdtls_start_or_attach()
	return require("lsp.serverCommon").start_or_attach(
		server_config_name,
		root_dir,
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
	local active_jdtls_clients = vim.lsp.get_clients({
		name = server_config_name
	})

	if (#active_jdtls_clients == 0) then
		if (is_jdt_uri_class_file)  then
			print("Error: trying to open a jdt:// URI but no jdtls clients")
			return
		end


		-- Opening a .class file before any .java file is valid
		-- Will start new jdtls client, attach, and use to decompile
		local client_id = jdtls_start_or_attach()
		local new_jdtls_client = vim.lsp.get_client_by_id(client_id)
		decompile(new_jdtls_client)

	-- 99% of use jdt:// buffers should take this branch
	elseif (#active_jdtls_clients == 1) then
		local only_jdtls_client = active_jdtls_clients[1]
		decompile(only_jdtls_client)
		vim.lsp.buf_attach_client(bufnr, only_jdtls_client.id)

	else
		local prompt = "Multiple jdtls clients found.\n"
		prompt = prompt .. "Presenting their root directories:\n"
		for i, client in ipairs(active_jdtls_clients) do
			prompt = prompt .. i .. ": Root Dir: " .. client.root_dir .. "\n"
		end
		prompt = prompt .. "Enter value for desired client: "


		local chosen_jdtls_client
		vim.ui.input({ prompt = prompt }, function(chosen_index)
			chosen_jdtls_client = active_jdtls_clients[tonumber(chosen_index)]
		end)
		vim.wait(60000, function() return chosen_jdtls_client ~= nil end)
		decompile(chosen_jdtls_client)
		vim.lsp.buf_attach_client(bufnr, chosen_jdtls_client.id)
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

