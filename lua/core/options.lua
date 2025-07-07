local outer_terminal = require("utils.outerTerminal")

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

-- Neovim 0.11.0 now defaults this option to the string:
-- internal,filler,closeoff,linematch:40
-- linematch:40 breaks gitsigns plugin. Specifically git_signs.preview_hunk()
-- https://github.com/lewis6991/gitsigns.nvim/issues/1278
vim.opt.diffopt = "internal,filler,closeoff"

-- Would prefer to use this instead of configuring the keymap for vim.lsp.buf.hover
-- However, it currently breaks telescope and neo-tree
-- https://github.com/nvim-telescope/telescope.nvim/issues/3436
-- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1743
-- vim.o.winborder = "rounded"

-- Basic plan for clipboard is as follows:
-- If on a local machine (tmux or not) use a local cli tool to copy and paste
-- For example, pbutil or xclip.
-- If over SSH without tmux, use OSC52 sequence
-- Everything described above is the default behavior in (:h clipboard)
-- If over SSH with tmux, use this custom code
-- TODO: Put up a PR to make this code part of neovim core default behavior.
local function paste_ocsf_tmux()
	local contents = nil
	local id = vim.api.nvim_create_autocmd('TermResponse', {
		callback = function(args)
			local resp = args.data.sequence ---@type string
			local encoded = resp:match('\027%]52;%w?;([A-Za-z0-9+/=]*)')
			if encoded then
				contents = vim.base64.decode(encoded)
				return true
			end
		end,
	})

	-- Request the contents of the outer console's clipboard
	-- '.' expands to the current pane (find target-pane in the manpages)
	-- By providing a target-pane, tmux will send the OSC52 response sequence
	-- Without target-pane, it just sets the tmux paste buffer (does not send)
	vim.system({ 'tmux', 'refresh-client', '-l', '.' })

	local ok, res

	-- Wait 1s first for terminals that respond quickly
	ok, res = vim.wait(1000, function() return contents ~= nil end, 100)

	if res == -1 then
		-- If no response was received after 1s, print a message and keep waiting
		vim.api.nvim_echo(
			{ { 'Waiting for OSC 52 response from the terminal. Press Ctrl-C to interrupt...' } },
			false,
			{}
		)
		ok, res = vim.wait(9000, function() return contents ~= nil end, 200)
	end

	if not ok then
		vim.api.nvim_del_autocmd(id)
		if res == -1 then
			vim.notify(
				'Timed out waiting for a clipboard response from the terminal',
				vim.log.levels.WARN
			)
		elseif res == -2 then
			-- Clear message area
			vim.api.nvim_echo({ { '' } }, false, {})
		end
		return 0
	end

	-- If we get here, contents should be non-nil
	return vim.split(assert(contents), '\n')
end

if outer_terminal.is_ssh then
	if outer_terminal.is_tmux then
		vim.g.clipboard = {
			name = 'Tmux OSC52',
			copy = {
				['+'] = 'tmux load-buffer -w -',
				['*'] = 'tmux load-buffer -w -',
			},
			paste = {
				['+'] = paste_ocsf_tmux,
				['*'] = paste_ocsf_tmux,
			},
		}
	else
		vim.g.clipboard = {
			name = 'OSC 52',
			copy = {
				['+'] = require('vim.ui.clipboard.osc52').copy('+'),
				['*'] = require('vim.ui.clipboard.osc52').copy('*'),
			},
			paste = {
				['+'] = require('vim.ui.clipboard.osc52').paste('+'),
				['*'] = require('vim.ui.clipboard.osc52').paste('*'),
			},
		}
	end
end

-- Default is "folds,cursor,curdir"
-- Remove curdir, this way view files do not update the working directory
-- https://neovim.io/doc/user/options.html#'viewoptions'
vim.opt.viewoptions = "folds,cursor"

-- Default is "blank,buffers,curdir,folds,help,tabpages,winsize,terminal"
-- Remove many things, and add globals
-- https://neovim.io/doc/user/options.html#'sessionoptions'
vim.opt.sessionoptions = "buffers,folds,globals"

-- I always want my statusline to be global
-- laststatus = 0 lies, it shows the statusline with horizontally split windows
-- https://github.com/neovim/neovim/issues/5626#issuecomment-186720136
-- I want to toggle it off globally with laststatus = 4, but that doesn't exist
vim.opt.laststatus = 3

-- The rest of the options (like line numbers and color column) are in:
-- require("core.myModules.hudKeymaps").default_display_preferences() ->
-- require("core.myModules.headsUpDisplay")
