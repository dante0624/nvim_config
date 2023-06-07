vim.cmd.colorscheme("tokyonight-moon")

-- Making the comments and the line numbers pop a little more
vim.cmd.highlight("CursorLine", "guibg=none")
vim.o.cursorline = true
vim.cmd.highlight("Comment", "guifg=#737aa2")
vim.cmd.highlight("LineNR", "guifg=#737aa2")
vim.cmd.highlight("CursorLineNR", "guifg=#73a0a2")

-- Remove background highlighting on folds
vim.cmd.highlight("Folded", "guibg=none")

