local Map = require("utils.map").Map

local function toboolean(str)
	return str == "true"
end

local M = {}

--[[ Table oriented way of going about this
Each Display is an interface which needs to implement:
	isShow()
		Return true, false, or nil
		nil generally means that something is wrong, like a plugin is not loaded
		When nil is returned, the calling function should generally do nothing
	show()
		Causes the display to be shown, even if it is already shown
	hide()
		Causes the display to be hidden, even if it is already hidden

	show() and hide() should use protected calls to check if a necessary plugin is ready,
	if not these functions should do nothing. ]]
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
	local original_buffer = vim.fn.bufnr()
	vim.opt.number = true
	vim.cmd('silent! bufdo set number')
	vim.cmd('buffer ' .. original_buffer)
end

function M.line_numbers.hide()
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

-- TODO:
-- Use vim.diagnostic with 3 methods calls to optionally hide diagnostics
-- enable, disable, and is_diabled
-- Wrap functions calls by saying that it is being enabled or disabled
-- Then make toggle call these wrapped functions
-- This is nice, because now toggle will tell you if it is on or off
-- Could be useful for diagnostics, or gitsigns where it is unclear
-- Remap these so that they start with h
-- Then remap gitsigns so that they start with s

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
Map('', '<Leader>hs', M.git_signs.toggle)
Map('', '<Leader>hd', M.diagnostics.toggle)


-- These functions can be used to quickly specify favorite sets of displays to show/hide
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

-- My own verion of "zen mode". I think its important to still show diagnostics
Map('', '<Leader>hz', function()
	onlyShow({'diagnostics'})
end)

-- Get rid of the header because "The Primagen" (p) suggests not using it
-- Use this when trying to immediately jump to buffers with <Control> {a-f}
Map('', '<Leader>hp', function()
	onlyHide({'header'})
end)

return M
