local Map = require("utils.map").Map

local function toboolean(str)
	return str == "true"
end

-- Sets an option to all buffers, then returns to the original_buffer
-- Happens immediately, appearing that the original buffer was never left
local function set_all(option)
	local original_buffer = vim.fn.bufnr()
	vim.cmd('silent! bufdo set ' .. option)
	vim.cmd('buffer ' .. original_buffer)
end

local M = {}

--[[ Table oriented way of going about this
Each table is an interface which needs to implement:
	isShown()
		Return true, false, or nil
		nil generally means that something is wrong,
		ex: a plugin is not loaded
		When nil is returned, the calling function should do nothing
	show()
		Causes the display to be shown, even if it is already shown
	hide()
		Causes the display to be hidden, even if it is already hidden

	show() and hide() should use pcalls to check dependency plugins.
		if the pcall fails, the functions should no-op ]]
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

M.line_numbers = {}
function M.line_numbers.isShown()
	return vim.o.number
end

function M.line_numbers.show()
	set_all("number")
end

function M.line_numbers.hide()
	set_all("nonumber")
end

M.color_column = {}
function M.color_column.isShown()
	return vim.o.colorcolumn == "80"
end

function M.color_column.show()
	set_all("colorcolumn=80")
end

function M.color_column.hide()
	set_all('colorcolumn=""')
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

M.diagnostics = {}
function M.diagnostics.isShown()
	return not vim.diagnostic.is_disabled()
end

function M.diagnostics.show()
	vim.diagnostic.enable()
end

function M.diagnostics.hide()
	vim.diagnostic.disable()
end

-- Give each display option certain new methods automatically
for display_name, display in pairs(M) do
	-- Give the ability to toggle
	function display.toggle()
		local shown = display.isShown()
		if shown == true then
			print("Hiding: " .. display_name)
			display.hide()
		elseif shown == false then
			print("Showing: " .. display_name)
			display.show()
		else
			print("Failed toggle call on: " .. display_name)
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

-- Prefix with h for HeadsUpDisplay
Map('', '<Leader>hh', M.header.toggle)
Map('', '<Leader>hf', M.footer.toggle)
Map('', '<Leader>hl', M.line_numbers.toggle)
Map('', '<Leader>hc', M.color_column.toggle)
Map('', '<Leader>hs', M.git_signs.toggle)
Map('', '<Leader>hd', M.diagnostics.toggle)


-- These can be used to set "favorite" HUD settings
-- Especially useful when set to a keymap
local function onlyShow(tbl)
	-- First hide everything
	for _, display in pairs(M) do
		display.hide()
	end

	for _, mode_name in ipairs(tbl) do
		M[mode_name].show()
	end
end
local function onlyHide(tbl)
	-- First show everything
	for _, mode in pairs(M) do
		mode.show()
	end

	for _, mode_name in ipairs(tbl) do
		M[mode_name].hide()
	end
end


-- Show no displays
Map('', '<Leader>hq', function()
	onlyShow({})
end)

-- Show all displays
Map('', '<Leader>ha', function()
	onlyHide({})
end)

-- My own verion of "zen mode".
-- I think its important to still show diagnostics
Map('', '<Leader>hz', function()
	onlyShow({'diagnostics'})
end)

-- Get rid of the header because "The Primagen" (p) suggests not using it
-- Use this when trying to immediately jump to buffers with <Control> {a-g}
Map('', '<Leader>hp', function()
	onlyHide({'header'})
end)

return M
