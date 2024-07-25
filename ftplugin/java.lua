local find_project_root = require("utils.paths").find_project_root

-- Sadly, I needed to copy - paste this into javaServer.lua
local root_dir, single_file = find_project_root({
	".git",
	"mvnw",
	"gradlew"
})
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

require("lsp.serverCommon").start_or_attach(
	"javaServer",
	root_dir,
	single_file
)

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
