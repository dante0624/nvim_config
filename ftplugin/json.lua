local folding = require("core.myModules.folding")

folding.setup_syntax_folding()

-- Use 2 spaces instead of tabs (jq cli command defaults to this)
vim.bo[0].tabstop = 2
vim.bo[0].shiftwidth = 2
vim.bo[0].expandtab = true
