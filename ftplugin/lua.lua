local find_project_root = require("utils.paths").find_project_root
local root_dir, single_file = find_project_root()
local folding = require("core.myModules.folding")

folding.setup_treesitter_folding()

--[[ Lua is strange, it likes to start its root directory at a lua/ dir
However, the init.lua file lives outside of this lua/ dir
So, we cannot just find the root by looking upwards for "lua/"
If we did this, and started at init.lua, we would never find the root

The solution is to find the project root by looking upwards for ".git"
Then, we check if a ./lua/ dir exists, and if so that becomes our root ]]
for name, type in vim.fs.dir(root_dir) do
	if name == "lua" and type == "directory" then
		root_dir = root_dir .. "lua/"
		break
	end
end

require("lsp.serverCommon").start_or_attach(
	"luaServer",
	root_dir,
	single_file
)
