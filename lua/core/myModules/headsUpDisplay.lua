local Map = require("utils.map").Map

local function toboolean(str)
	return str == "true"
end

local M = {}

-- New, table oriented way of going about this
M.header = {}
function M.header.isShown()
	return vim.o.showtabline ~= 0
end
function M.header.show()
	vim.opt.showtabline = 2
end
function M.header.hide()
	vim.opt.showtabline = 0
end

M.footer = {}
function M.footer.isShown()
	return vim.o.laststatus ~= 0
end
function M.footer.show()
	vim.opt.laststatus = 2
end
function M.footer.hide()
	vim.opt.laststatus = 0
end

M.numbers = {}
function M.numbers.isShown()
	return vim.o.number
end
function M.numbers.show()
	local original_buffer = vim.fn.bufnr()
	vim.opt.number = true
	vim.cmd('silent! bufdo set number')
	vim.cmd('buffer ' .. original_buffer)
end
function M.numbers.hide()
	local original_buffer = vim.fn.bufnr()
	vim.opt.number = false
	vim.cmd('silent! bufdo set nonumber')
	vim.cmd('buffer ' .. original_buffer)
end

M.git_signs = {}
function M.git_signs.isShown()
	local gitsigns_ok, _ = pcall(require, "gitsigns")
	if not gitsigns_ok then
		return nil
	end

	return require('gitsigns.config').config.signcolumn
end
function M.git_signs.show()
	local shown = M.git_signs.isShown()
	if shown == false then
		vim.cmd('silent! Gitsigns toggle_signs')
	end
end
function M.git_signs.hide()
	local shown = M.git_signs.isShown()
	if shown == true then
		vim.cmd('silent! Gitsigns toggle_signs')
	end
end


-- Give each display option certain new methods automatically
for display_name, display in pairs(M) do
	-- Give the ability to toggle
	function display.toggle()
		local shown = display.isShown()
		if shown == true then
			display.hide()
		end

		if shown == false then
			display.show()
		end
	end

	-- Give the ability to save
	function display.save()
		vim.g["HUD_" .. display_name] = tostring(display.isShown())
	end

	-- Give the ability to restore
	function display.restore()
		local saved_option = toboolean(vim.g["HUD_" .. display_name])
		if saved_option == true then
			display.show()
		end

		if saved_option == false then
			display.hide()
		end
	end
end


-- s, short for "show"
Map('', '<Leader>sk', M.header.toggle)
Map('', '<Leader>sj', M.footer.toggle)
Map('', '<Leader>sl', M.numbers.toggle)
Map('', '<Leader>sh', M.git_signs.toggle)

-- Open or close all display options
Map('', '<Leader>so', function()
	for _, display in pairs(M) do
		display.show()
	end
end)

Map('', '<Leader>sc', function()
	for _, display in pairs(M) do
		display.hide()
	end
end)

return M

