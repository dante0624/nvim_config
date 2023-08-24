-- Protected call is needed when packer is used for the first time
local status_ok, _ = pcall(vim.cmd.colorscheme, "tokyonight-moon")
if not status_ok then
  return false
end

-- Making the comments and the line numbers pop a little more
vim.cmd.highlight("CursorLine", "guibg=none")
vim.o.cursorline = true
vim.cmd.highlight("Comment", "guifg=#737aa2")
vim.cmd.highlight("LineNR", "guifg=#737aa2")
vim.cmd.highlight("CursorLineNR", "guifg=#73a0a2")

-- Remove background highlighting on folds
vim.cmd.highlight("Folded", "guibg=none")

-- Make DocStrings have the same hue as normal strings, just less bright and italicized
vim.cmd.highlight("@string.documentation", "guifg=#a6c478")
vim.cmd.highlight("@string.documentation", "cterm=italic")
vim.cmd.highlight("@string.documentation", "gui=italic")

