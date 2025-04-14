local paths = require("utils.paths")
local os = require("utils.os")
local architecture = require("utils.architecture")
local create_buffer = require("utils.buffers").create_buffer

-- Sadly, I needed to copy - paste this from java.lua
local root_dir, _ = paths.find_project_root({
	".git",
	"mvnw",
	"gradlew"
})

local inferred_workspace = paths.Java_Workspaces
	.. paths.serialize_path(root_dir)
local jdtls_dir = paths.Mason_Path .. "packages/jdtls/"
local os_config
if os.is_linux_os then
	os_config = "config_linux"
elseif os.is_macos then
	os_config = "config_mac"
elseif os.is_wsl then
	os_config = "config_ss_linux"
elseif os.is_windows then
	os_config = "config_win"
end

-- For some reason, the distribution of jdtls through mason does not come with config_win_arm
if architecture.is_arm and not os.is_windows then
	os_config = os_config .. "_arm"
end

-- Essentially do a regex search on a directory to find this jar file
local launcher_file = vim.fn.globpath(jdtls_dir .. "plugins", "*launcher_*")

-- Logic needed to handle go-to-definition and decompiling a class file
-- definition argument is a table with the following format:
-- {
-- 	range = {
-- 		end = {
-- 			character = int
-- 			line = int
-- 		}
-- 		start = {
-- 			character = int
-- 			line = int
-- 		}
-- 	}
-- 	uri = string
-- }
local function open_classfile(definition, client_id)
	local bufnr = create_buffer(definition.uri)

	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].buftype = 'nofile'

	local client = vim.lsp.get_client_by_id(client_id)

	local content
	local function handler(_, result)
		content = result
		local normalized = string.gsub(result, '\r\n', '\n')
		local source_lines = vim.split(normalized, "\n", { plain = true })
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, source_lines)
		vim.bo[bufnr].modifiable = false
	end

	local params = {
		uri = definition.uri
	}
	client:request("java/classFileContents", params, handler, bufnr)
	-- Need to block. Otherwise logic could run that sets the cursor
	-- to a position that's still missing.
	local timeout_ms = 5000
	vim.wait(timeout_ms, function() return content ~= nil end)

	-- Focus on buffer and set cursor to desired position
	vim.cmd("buffer " .. bufnr)
	local buffer_window =
		vim.api.nvim_call_function("bufwinid", { bufnr })
	local position = definition.range.start
	vim.api.nvim_win_set_cursor(buffer_window, { position.line + 1, position.character })

	-- Before running ftplugin/java, must store client_id in a local var
	vim.fn.setbufvar(bufnr, "java_decomp_client_id", client_id)

	-- Triggers ftplugin/java
	vim.bo[bufnr].filetype = 'java'
end

local custom_go_to_definition = function()
	vim.lsp.buf_request_all(0, 'textDocument/definition', vim.lsp.util.make_position_params(0, "utf-8"), function(results)
		for client_id, client_result in ipairs(results) do
			for _, definition in ipairs(client_result.result) do
				if vim.startswith(definition.uri, "jdt://") then
					open_classfile(definition, client_id)
				else
					vim.lsp.buf.definition()
				end
			end
		end
	end)
end


return {
	cmd = {
		"java", -- or '/path/to/java17_or_newer/bin/java'
		-- java17 or newer needs to be on the path

		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		-- Add lombok support
		"-javaagent:" .. jdtls_dir .. "lombok.jar",

		-- This will depend on the version of jdtls installed
		"-jar",
		launcher_file,

		-- This will depend on the machine os
		"-configuration",
		jdtls_dir .. os_config,

		-- Very proud of how I handled this
		-- It creates data directories under a new folder in the Data_Dir
		-- But it makes a new, nicely named folder, for each different project
		"-data",
		inferred_workspace,
	},

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	pre_attach_settings = {
		java = {
			-- Don't try to build the project automatically
			-- Let me decide when to run the build commands
			autobuild = {
				enabled = false,
			},

			-- If true, will run run gradle buildship on startup (auto-generates .classpath file based on gradle config)
			-- Set to false if you don't want .classpath files being overwritten
			-- Set to true if making a simple gradle project, and this auto-generation is helpful
			import = {
				gradle = {
					enabled = true,
				},
			},

			-- Formatting options
			-- By default will insert tabs by whenever the "create method" code action is used
			-- Instead use spaces, since Java Checkstyle linter prefers spaces
			format = {
				insertSpaces = true,
			},
		},
	},

	-- Language server `initializationOptions`
	-- 'bundles' can specify paths to jar files for eclipse.jdt.ls plugins
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	-- This could later be used for debuggers
	init_options = {
		bundles = {
			-- "path/to/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
			-- "/path/to/microsoft/vscode-java-test/server/*.jar",
		},

		-- Gives extra code action capabilities
		extendedClientCapabilities = {
			classFileContentsSupport = true,
			generateToStringPromptSupport = true,
			hashCodeEqualsPromptSupport = true,
			advancedExtractRefactoringSupport = true,
			advancedOrganizeImportsSupport = true,
			generateConstructorsPromptSupport = true,
			generateDelegateMethodsPromptSupport = true,
			moveRefactoringSupport = true,
			overrideMethodsPromptSupport = true,
			executeClientCommandSupport = true,
			inferSelectionSupport = {
				"extractMethod",
				"extractVariable",
				"extractConstant",
				"extractVariableAllOccurrence"
			},
		},
	},
	keymap_overrides = function(_, bufnr)
		vim.keymap.set("n", "gd", custom_go_to_definition, { buffer = bufnr })
	end,
}
