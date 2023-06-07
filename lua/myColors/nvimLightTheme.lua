vim.cmd.colorscheme("tokyonight-day")

-- Making the comments and the line numbers pop a little more
vim.cmd.highlight("CursorLine", "guibg=none")
vim.o.cursorline = true
vim.cmd.highlight("Comment", "guifg=#68709a")
vim.cmd.highlight("LineNR", "guifg=#68709a")
vim.cmd.highlight("CursorLineNR", "guifg=#2496ac")

-- Remove background highlighting on folds
vim.cmd.highlight("Folded", "guibg=none")

-- Make my Background less bright
vim.cmd.highlight("Normal", "guibg=#d8d8d8")
vim.cmd.highlight("NormalNC", "guibg=#d8d8d8")

-- Make the tree less bright as well
vim.cmd.highlight("NvimTreeNormal", "guibg=#d8d8d8")
vim.cmd.highlight("NvimTreeNormalNC", "guibg=#d8d8d8")



