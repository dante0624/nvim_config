local M = {}

local function toboolean(str)
	return str == "true"
end

-- Deals with the header, aka the tabline at the top
M.toggle_header = function()
	local next_tabline
	if vim.o.showtabline == 0 then
		next_tabline = 2
	else
		next_tabline = 0
	end

	vim.opt.showtabline = next_tabline
end
M.save_header = function()
	vim.g.Toggling_header_state = tostring(vim.o.showtabline)
end
M.restore_header = function()
	vim.opt.showtabline = tonumber(vim.g.Toggling_header_state)
end

-- Deals with the footer, aka lualine at the bottom
M.toggle_footer = function()
	local next_statusline
	if vim.o.laststatus == 0 then
		next_statusline = 2
	else
		next_statusline = 0
	end

	vim.opt.laststatus = next_statusline
end
M.save_footer = function()
	vim.g.Toggling_footer_state = tostring(vim.o.laststatus)
end
M.restore_footer = function()
	vim.opt.laststatus = tonumber(vim.g.Toggling_footer_state)
end

-- Deals with whether or not the lines are numbered
local function set_all_line_numbers(bool)
	local original_buffer = vim.fn.bufnr()
	if bool then
		vim.opt.number = true
		vim.cmd('silent! bufdo set number')
	else
		vim.opt.number = false
		vim.cmd('silent! bufdo set nonumber')
	end
	vim.cmd('buffer ' .. original_buffer)
end

M.toggle_line_numbers = function()
	set_all_line_numbers(not vim.o.number)
end
M.save_line_numbers = function()
	vim.g.Toggling_number_state = tostring(vim.o.number)
end
M.restore_line_numbers = function()
	set_all_line_numbers(toboolean(vim.g.Toggling_number_state))
end


-- Deals with Gitsigns plugin
local function toggle_git_signs()
	vim.cmd('Gitsigns toggle_signs')
end
M.toggle_git_signs = toggle_git_signs

-- This just is a way to 'get' whether or not the gitsigns are currently displayed
local config = require('gitsigns.config').config

M.save_git_signs = function()
	vim.g.Toggling_git_signs = tostring(config.signcolumn)
end
M.restore_git_signs = function()
	if not toboolean(vim.g.Toggling_git_signs) then
		toggle_git_signs()
	end
end

return M

