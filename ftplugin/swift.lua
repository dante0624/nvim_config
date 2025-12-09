local find_project_root = require("utils.paths").find_project_root
local folding = require("core.myModules.folding")

local root_dir, is_single_file = find_project_root()

--[[ The Swift treesitter syntax requires installing from grammar.

Running `TSInstall swift` will give an error like:
```
tree-sitter CLI not found: `tree-sitter` is not executable!
tree-sitter CLI is needed because `swift` is marked that it needs to be generated from the grammar definitions to be compatible with nvim!
```

This could be fixed with `brew install tree-sitter-cli` (macOS example). Then `TSInstallFromGrammar swift` will work.
But I don't use swift enough that its worth installing the `tree-sitter` CLI just for this.
So, just use the standard syntax highlighting for now.]]
folding.setup_syntax_folding()

require("lsp.serverCommon").start_or_attach(
	"swiftServer",
	root_dir,
	is_single_file
)

require("lsp.serverCommon").start_or_attach(
	"cspellServer",
	root_dir,
	is_single_file
)

-- Run command
vim.b.run_command = 'swift "' .. vim.fn.expand("%:p") .. '"'
