local paths = require("utils.paths")
local os = require("utils.os")

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
if os.is_linux_os or os.is_wsl then
	os_config = "config_linux"
elseif os.is_macos then
	os_config = "config_mac"
elseif os.is_windows then
	os_config = "config_win"
end

-- Essentially do a regex search on a directory to find this jar file
local launcher_file = vim.fn.globpath(jdtls_dir .. "plugins", "*launcher_*")

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
			autobuild = {
				enabled = false,
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
}
