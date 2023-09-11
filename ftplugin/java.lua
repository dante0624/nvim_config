local dir = require("utils.directories")
local Local_Map = require("utils.map").Local_Map
local shell = require("utils.shell")
local os = require("utils.os")

-- Gives me the same keymaps as other lsps
local lsp_on_attach = require("lsp.handlers").on_attach

-- Find the root directory, returns nil if not found
local root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'})
local single_file = root_dir == nil

if single_file then
	root_dir = vim.fn.expand('%:p:h') -- The folder that the current buffer is in
end

local root_dir_ending = vim.fn.fnamemodify(root_dir, ':t')

local inferred_workspace = dir.Java_Workspaces .. root_dir_ending
local jdtls_dir = dir.Data_Dir .. "mason/packages/jdtls/"
local os_config
if os.is_unix or os.is_wsl then
	os_config = "config_linux"
elseif os.is_macos then
	os_config = "config_mac"
elseif os.is_windows then
	os_config = "config_win"
end

-- Essentially do a regex search on a directory to find this jar file
local launcher_file_path = vim.fn.globpath(jdtls_dir .. 'plugins', '*launcher_*')

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.local config = {
-- The command that starts the language server
-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
local config = {
	cmd = {
		'java', -- or '/path/to/java17_or_newer/bin/java'
				-- depends on if `java` is in your $PATH env variable and if it points to the right version.

		'-Declipse.application=org.eclipse.jdt.ls.core.id1',
		'-Dosgi.bundles.defaultStartLevel=4',
		'-Declipse.product=org.eclipse.jdt.ls.core.product',
		'-Dlog.protocol=true',
		'-Dlog.level=ALL',
		'-Xmx1g',
		'--add-modules=ALL-SYSTEM',
		'--add-opens', 'java.base/java.util=ALL-UNNAMED',
		'--add-opens', 'java.base/java.lang=ALL-UNNAMED',

		-- This line was modified by me, it is a jar file that can vary based on version or os
		'-jar', launcher_file_path,

		-- Same with this line, the ending is dependent on operating system
		'-configuration', jdtls_dir .. os_config,

		-- Very proud of how I handled this, it creates data directories under a new folder in the Data_Dir
		-- But it makes a new, nicely named folder, for each different project
		'-data', inferred_workspace
	},

	-- This is critical for the LSP to work project wide
	root_dir = root_dir,

	-- Gives me the same Keybinds as other LSPs and highlighting stuff
	on_attach = lsp_on_attach,

	-- Trying to make LspInfo look nice
	autostart = true,
	filetypes = { 'java', },

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request for a list of options
	settings = {
		java = {
			autobuild = {
				enabled = false,
			},
		},
	},

	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files if you want to use additional eclipse.jdt.ls plugins.
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
require('jdtls').start_or_attach(config)


-- Start of the keymappings for quickly building and running
local separator
if shell.is_powershell then
	separator = " ; "
else
	separator = " && "
end

if single_file then
	local full_fname = vim.fn.expand('%:p')
	local build_cmd = 'javac "'..full_fname..'"'
	local class_name = vim.fn.expand('%:p:t:r')
	local run_command = build_cmd..separator..'java -cp "'..root_dir..'" '..class_name
	Local_Map(
		{ 'n', 'v' },
		'<Leader><CR>',
		'<Cmd>ToggleTerm<CR>'..run_command..'<CR>'
	)
else
	Local_Map(
		{ 'n', 'v' },
		'<Leader><CR>',
		'<Cmd>ToggleTerm<CR>gradle build<CR>'
	)
end

