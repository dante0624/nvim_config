local find_project_root = require("utils.paths").find_project_root
local dap_utils = require("utils.dapUtils")

local M = {}

---@alias ResultStatusCode
---| 0 # SUCCESS
---| 1 # ROOT_NODE_REACHED
---| 2 # CHILD_NOT_FOUND

local function go_up_until(node, up_until_type)
	local root_most_node = node

	while root_most_node:type() ~= up_until_type do
		local parent = root_most_node:parent()
		if parent == nil then
			return 1, root_most_node
		end
		root_most_node = parent
	end

	return 0, root_most_node
end

local function get_child_with_type(node, child_type)
	local desired_child_node = nil
	for child in node:iter_children() do
		if child:type() == child_type then
			desired_child_node = child
			break
		end
	end
	if desired_child_node == nil then
		return 2, desired_child_node
	end
	return 0, desired_child_node
end

local function node_to_buffer_text(node)
	local start_row, start_col, end_row, end_col = node:range()
	local read_lines = vim.api.nvim_buf_get_text(
		0,
		start_row,
		start_col,
		end_row,
		end_col,
		{}
	)
	local result = ""
	for _, text in ipairs(read_lines) do
		result = result .. text:gsub("%s", "")
	end
	return result
end



--- A helper function for finding text by walking a parsed tree
---
--- A common way to use treesitter's tree is to answer a question like
--- "what function is my cursor currently in?"
--- 
--- Answering this question involves 4 steps:
---   1. Get the node where the cursor currently is
---   2. Navigate up until some node represents the entire function
---   3. Go to a specific child of that node, which is the function's name
---   4. Use that node's range to get the function's name from the buffer
--- 
--- function acts as a framework for this common use case.
---
--- @param start_node TSNode starting point
--- @param up_until_type string node type to move upwards until finding
--- @param child_type string node type to look for in the immediate children
--- @return ResultStatusCode status indicating success or failure
--- @return string result of the navigation. Empty String if result_code ~= 0.
--- @return TSNode root_most_node the closest to root the navigation reached
local function treesitter_navigate(start_node, up_until_type, child_type)
	local move_up_status, root_most_node = go_up_until(
		start_node,
		up_until_type
	)
	if move_up_status ~= 0 then
		return move_up_status, "", root_most_node
	end

	local get_child_status, desired_child_node = get_child_with_type(
		root_most_node,
		child_type
	)
	if get_child_status ~= 0 then
		return get_child_status, "", root_most_node
	end

	local buffer_text = node_to_buffer_text(desired_child_node)
	return 0, buffer_text, root_most_node
end

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

	local get_method_status, method_name, method_node = treesitter_navigate(
		start_node,
		"method_declaration",
		"identifier"
	)
	if get_method_status ~= 0 then
		print("Treesitter walking failed to find method name")
		return
	end

	local get_class_status, full_class_name, class_node = treesitter_navigate(
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
		get_class_status, parent_class_name, class_node = treesitter_navigate(
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
	local get_package_status, package_node = get_child_with_type(
		root_node,
		"package_declaration"
	)
	-- It is legal for Java classes to not have a package declaration
	if get_package_status ~= 0 then
		return full_class_name .. "." .. method_name
	end

	local get_package_name_status, package_name_node = get_child_with_type(
		package_node,
		"identifier" -- Used for a single dir like "package x";
	)
	if get_package_name_status ~= 0 then
		get_package_name_status, package_name_node = get_child_with_type(
			package_node,
			"scoped_identifier" -- Used for multiple dirs like "package x.y"
		)
	end
	if get_package_name_status ~= 0 then
		print("Treesitter walking failed to find package name")
		return
	end

	local package_name = node_to_buffer_text(package_name_node)
	return package_name .. "." .. full_class_name .. "." .. method_name
end

M.server_config_name = "javaServer"

--- Searches upward to find the root of the project,
--- where a build command such as "gradle build" could be run.
--- @return string project_root_dir the project root if single_file == false,
---     otherwise it is the directory where the current file is located.
--- @return boolean single_file true if a project root could not be found.
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
--- @return boolean single_file true if a project root could not be found.
function M.get_jdtls_root_dir()
	-- Modify me to be different if working on multiple projects
	return M.get_project_root_dir()
end

--- If there are 0 jdtls clients active, return nil
--- If there is 1 jdtls client active, return that client
--- If there are multiple jdtls clients active, prompt user to select
--- @return vim.lsp.Client|nil the chosen jdtls client
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


function M.start_debug()
	local full_method_path = M.get_full_method_path()
	if full_method_path == nil then
		return
	end

	local build_dir, single_file = M.get_project_root_dir()
	if single_file then
		print("Could not find build directory, cannot start debugging")
		return
	end

	local client = M.get_chosen_lsp_client()
	if client == nil then
		print("Need an active jdtls client to start debugging")
		return
	end

	local debugee_command = {
		'gradle',
		'--rerun-tasks',
		'test',
		'--tests',
		full_method_path,
		'--debug-jvm',
	}
	local debugee_configuration = {
		type = "java",
		request = "attach",
		name = "Java Debug";
		hostName = "127.0.0.1";
		port = 5005;
	}
	local debugee_ready = false
	local debugger_configuration = nil
	local debugger_ready = false

	-- Start the debugee process
	local read_stdin = function(err, data)
		assert(not err, err)
		if data == nil then
			return
		end
		if data:find("Listening for transport dt_socket at address: 5005") then
			debugee_ready = true
		end
	end
	local system_obj = vim.system(debugee_command, {
		cwd = build_dir,
		stdout = read_stdin,
		text = true,
	}, function(obj)
		-- If the debugee ends, terminate the session but print the exit code
		dap_utils.terminate_and_cleanup()
		print("debugee exit code", obj.code)
	end)

	print("Debugee PID", system_obj.pid)

	-- Start the debuger thread
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

	print("Waiting for debugger and debugee to be ready")
	vim.wait(5000, function() return debugger_ready and debugee_ready end)
	require("dap").attach(debugger_configuration, debugee_configuration)
end

return M
