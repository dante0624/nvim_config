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
vim.opt.ts = 4
vim.opt.sw = 4

-- When a line is wrapped, we continue indent the wrapping to match
vim.opt.breakindent = true

-- All lowercase searches are case insensitive
-- But searches with any uppercase characters are case sensitive
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- The rest of the options (like line numbers and color column) are in:
-- require("core.myModules.hudKeymaps").default_display_preferences() ->
-- require("core.myModules.headsUpDisplay")
