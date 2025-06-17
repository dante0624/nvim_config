local paths = require("utils.paths")
local os = require("utils.os")
local architecture = require("utils.architecture")
local java_utils = require("utils.javaUtils")

local jdtls_root_dir, _ = java_utils.get_jdtls_root_dir()

local inferred_workspace = paths.Java_Workspaces
	.. paths.serialize_path(jdtls_root_dir)
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

return {
	cmd = {
		"java", -- or '/path/to/java21 (only version I've had success with)

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
			-- A really great alternative is to force jdtls to import as an eclipse project before gradle:
			-- https://github.com/eclipse-jdtls/eclipse.jdt.ls/issues/257#issuecomment-350598939
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
	init_options = {
		-- https://github.com/microsoft/java-debug does not have a "public static void main()" method
		-- This means that it cannot easily be invoked as a standalone debugger from the commandline
		-- Instead, it is designed to get bundled with jdtls, and jdtls starts the process
		bundles = {
			paths.Mason_Path .. "share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
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
}
