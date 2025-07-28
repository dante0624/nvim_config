local find_project_root = require("utils.paths").find_project_root
local dap_utils = require("utils.dapUtils")
local ts_util = require("utils.treesitter")

local M = {}

--- Uses treesitter to find the package path, Class, inner classes (optional),
--- and the method name.
--- Return the result as packagePath.Class.InnerClass.methodName
--- @return string|nil full_method_path nil if an error was encountered
function M.get_full_method_path()
	local start_node = vim.treesitter.get_node()
	if start_node == nil then
		print("Treesitter parsing failed to get node under cursor")
		return
	end

	local get_method_status, method_name, method_node = ts_util.treesitter_navigate(
		start_node,
		"method_declaration",
		"identifier"
	)
	if get_method_status ~= 0 then
		print("Treesitter walking failed to find method name")
		return
	end

	local get_class_status, full_class_name, class_node = ts_util.treesitter_navigate(
		method_node,
		"class_declaration",
		"identifier"
	)
	if get_class_status ~= 0 then
		print("Treesitter walking failed to find class name")
		return
	end

	-- Enter a loop of navigating up through inner classes
	-- Go until until root node is reached
	local parent_class_name
	while get_class_status ~= 1 do
		local immediate_class_parent = class_node:parent()
		if immediate_class_parent == nil then
			break
		end
		get_class_status, parent_class_name, class_node = ts_util.treesitter_navigate(
			immediate_class_parent,
			"class_declaration",
			"identifier"
		)
		if get_class_status == 2 then
			print("Treesitter walking failed to identify a parent class")
			return
		end
		if get_class_status == 0 then
			full_class_name = parent_class_name .. "." .. full_class_name
		end
	end

	local root_node = start_node:tree():root()
	local get_package_status, package_node = ts_util.get_child_with_type(
		root_node,
		"package_declaration"
	)
	-- It is legal for Java classes to not have a package declaration
	if get_package_status ~= 0 then
		return full_class_name .. "." .. method_name
	end

	local get_package_name_status, package_name_node = ts_util.get_child_with_type(
		package_node,
		"identifier" -- Used for a single dir like "package x";
	)
	if get_package_name_status ~= 0 then
		get_package_name_status, package_name_node = ts_util.get_child_with_type(
			package_node,
			"scoped_identifier" -- Used for multiple dirs like "package x.y"
		)
	end
	if get_package_name_status ~= 0 then
		print("Treesitter walking failed to find package name")
		return
	end

	local package_name = ts_util.node_to_buffer_text(package_name_node)
	return package_name .. "." .. full_class_name .. "." .. method_name
end

M.server_config_name = "javaServer"
M.terminal_display_name = "Java_Debugee_Terminal"
M.debugee_port = 5005 -- Default when passing --debug-jvm to Gradle

--- Searches upward to find the root of the project,
--- where a build command such as "gradle build" could be run.
--- @return string project_root_dir the project root if single_file == false,
---     otherwise it is the directory where the current file is located.
--- @return boolean is_single_file true if a project root could not be found.
function M.get_project_root_dir()
	return find_project_root({
		".git",
		"mvnw",
		"gradlew"
	})
end

--- Method will be different from find_project_root_dir() only if using a
--- multi-project setup, with workspace folders.
--- @return string jdtls_root_dir the desired root_dir for jdtls.
--- @return boolean is_single_file true if a project root could not be found.
function M.get_jdtls_root_dir()
	-- Modify me to be different if working on multiple projects
	return M.get_project_root_dir()
end

--- If there are 0 jdtls clients active, return nil
--- If there is 1 jdtls client active, return that client
--- If there are multiple jdtls clients active, prompt user to select
--- @return vim.lsp.Client|nil client the chosen jdtls client
function M.get_chosen_lsp_client()
	local active_jdtls_clients = vim.lsp.get_clients({
		name = M.server_config_name
	})

	if (#active_jdtls_clients == 0) then
		return

	elseif (#active_jdtls_clients == 1) then
		return active_jdtls_clients[1]
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
		return chosen_jdtls_client
	end
end

--- Use the command "java.project.listSourcePaths" to determine the project name.
--- Ask the language server for this information rather than parsing a file like:
--- pom.xml, settings.gradle.kts, or .project
--- The jdtls server has already parsed these files
--- @param client vim.lsp.Client
--- @return string|nil project_name the project_name, if successful
function M.get_current_project_name(client)
	local client_result_parsed = false
	local project_name = nil

	local current_buffer_path = vim.fn.expand("%:p")
	client:request(
		"workspace/executeCommand",
		{ command = "java.project.listSourcePaths" },
		function(err, result)
			if err then
				print("Error calling java.project.listSourcePaths", err)
				client_result_parsed = true
				return
			end

			for _, source_path_entry in ipairs(result.data) do
				if vim.startswith(current_buffer_path, source_path_entry.path) then
					client_result_parsed = true
					project_name = source_path_entry.projectName
					return
				end
			end

			print("Could not determine the current project name")
			client_result_parsed = true
		end
	)

	-- Block up to 5 seconds until the client responds and the result is parsed
	-- The result should come quickly 
	vim.wait(5000, function() return client_result_parsed end)
	return project_name
end

--- Thing wrapper around vim.system, which polls a port
--- @param opts vim.SystemOpts? Options table
--- @param on_exit? fun(out: vim.SystemCompleted) Called when subprocess exits. Runs async if non-nil.
--- @return vim.SystemObj Object which can be used to wait for the process to exit
function M.poll_if_debugee_port_listening(opts, on_exit)
	return vim.system({ "lsof", "-P", "-i", "TCP@localhost:" .. M.debugee_port}, opts, on_exit)
end

--- Starts a new debugging session
--- If port 5005 is already in use, use that as the debugee
--- Otherwise, start a new debugee running a single unit test
--- @param client vim.lsp.Client active, attached JDTLS client
function M.start_debug(client)
	-- Needed for REPL debugging to work, for some reason
	local project_name = M.get_current_project_name(client)
	if project_name == nil then
		print("Cloud not determine the project name")
		return
	end

	-- This gets passed to the debugger, telling it about the debugee
	local debugee_configuration = {
		type = "java",
		request = "attach",
		name = "Java Debug",
		projectName = project_name,
		hostName = "127.0.0.1",
		port = M.debugee_port,
	}
	local debugee_ready = false

	-- This gets passed to nvim-dap, telling it about the debugger
	local debugger_configuration = nil
	local debugger_ready = false

	if M.poll_if_debugee_port_listening(nil, nil):wait(500).code == 0 then
		print(
			"Process is already listening on port " ..
			M.debugee_port ..
			". Assuming this is a debugee and attaching."
		)
		debugee_ready = true

	-- Start a new debugee is a new, background, toggleable terminal
	else
		local project_dir, is_single_file = M.get_project_root_dir()
		if is_single_file then
			print("Could not find project directory, cannot start debugging")
			return
		end

		local full_method_path = M.get_full_method_path()
		if full_method_path == nil then
			print("Could not determine unit test method to debug")
			return
		end

		local debugee_command = "gradle --rerun-tasks test --tests " .. full_method_path .. " --debug-jvm"

		local terminal_plugin = require("toggleterm.terminal")
		local old_debugee_term = terminal_plugin.find(function(term)
			return term.display_name == M.terminal_display_name
		end)
		if old_debugee_term ~= nil then
			old_debugee_term:shutdown()
		end
		local new_debugee_term = terminal_plugin.Terminal:new({
			auto_scroll = false,
			close_on_exit = false,
			cmd = debugee_command,
			dir = project_dir,
			display_name = M.terminal_display_name,
			hidden = true,
			on_exit = function(_, _, exit_code, _)
				dap_utils.terminate_and_cleanup()
				print("Debugee exit code", exit_code)
			end,
		})
		new_debugee_term.bufnr = require("toggleterm.ui").create_buf()
		new_debugee_term:__add()

		-- Starts the debugee running in the background
		print("Starting a new debugee is a new, background, toggleable terminal")
		vim.api.nvim_buf_call(new_debugee_term.bufnr, function() new_debugee_term:__spawn() end)
	end

	-- Start the debugger thread
	client:request(
		"workspace/executeCommand",
		{ command = "vscode.java.startDebugSession" },
		-- Callback function, where jdtls responds with the port
		function(err, port, _)
			if (err) then
				print("There was an error starting java-debug adapter")
				print(vim.inspect(err))
				return
			end

			debugger_configuration = {
				type = "server",
				port = port,
			}
			debugger_ready = true
		end
	)

	print("Waiting for a maximum of 30 seconds for the Debugger and Debugee to be ready")
	local start_ms = vim.uv.now()
	local timer = vim.uv.new_timer()
	timer:start(0, 1000, function()
		if debugger_ready and debugee_ready then
			timer:stop()
			timer:close()
			print("Debugger and Debugee both ready")
			vim.schedule(function() require("dap").attach(debugger_configuration, debugee_configuration) end)
			return
		end

		if vim.uv.now() - start_ms > 30000 then
			timer:stop()
			timer:close()
			if (not debugger_ready) and (not debugee_ready) then
				print("Failed to start both Debugger and Debugee")
			elseif not debugger_ready then
				print("Failed to start Debugger")
			else
				print("Failed to start Debugee")
			end
			return
		end

		M.poll_if_debugee_port_listening({ timeout = 500}, function(out)
			debugee_ready = debugee_ready or out.code == 0
		end)

	end)
end

return M
