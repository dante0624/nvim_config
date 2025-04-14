local is_ssh_x11 = require("utils.ssh").is_ssh_x11

-- Many of these options get overwritten by
-- editorconfig.lua (a lua file built in to neovim)
-- Useful to read the file, but I don't like it overwriting my values
vim.g.editorconfig = false

vim.opt.background = "dark"

-- Don't automatically make the next line a comment if the current line is
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "*",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- Opens new buffers to the right and below
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Make the cursor always be a block (a is for all modes)
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	pattern = "*",
	callback = function()
		vim.opt.guicursor = "a:block"
	end,
})

-- Contols how many spaces a tab (indent) turns into
-- These 3 are all buffer local options
-- They can be overwritten within an ftplugin file
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

-- When a line is wrapped, we continue indent the wrapping to match
vim.opt.breakindent = true

-- All lowercase searches are case insensitive
-- But searches with any uppercase characters are case sensitive
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Needed for hover windows from LSP. Breaking change from Neovim 0.11
vim.o.winborder = "rounded"

-- If ssh with X11 forwarding, force + and * clipboards to use Xclip
-- Otherwise, use neovim's default clipboard
if is_ssh_x11 then
	vim.g.clipboard = {
		name = 'XClip',
		copy = {
			['+'] = 'xclip -in -selection clipboard',
			['*'] = 'xclip -in -selection clipboard',
		},
		paste = {
			['+'] = 'xclip -out -selection clipboard',
			['*'] = 'xclip -out -selection clipboard',
		},
	}
end


-- The rest of the options (like line numbers and color column) are in:
-- require("core.myModules.hudKeymaps").default_display_preferences() ->
-- require("core.myModules.headsUpDisplay")
