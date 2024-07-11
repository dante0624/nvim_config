local os = require("utils.os")
local paths = require("utils.paths")
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

-- Gives me the same keymaps as other lsps
local lsp_on_attach = require("lsp.serverCommon").on_attach_keymaps

-- Find the root directory, returns nil if not found
local root_dir, single_file = paths.find_project_root({
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

-- See `:help vim.lsp.start_client` for the supported `config` options.
-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
local config = {
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

	-- This is critical for the LSP to work project wide
	root_dir = root_dir,

	-- Gives me the same Keybinds as other LSPs and highlighting stuff
	on_attach = lsp_on_attach,

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	settings = {
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
	},
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)

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
