local buf_versions = require('vim.lsp.util').buf_versions
local get_full_text = require('utils.buffers').get_full_text

-- Sets an option to all buffers, then returns to the original_buffer
-- Happens immediately, appearing that the original buffer was never left
local function set_all(option)
	local original_buffer = vim.fn.bufnr()
	vim.cmd("silent! bufdo set " .. option)
	vim.cmd("buffer " .. original_buffer)
end

-- Makes all active LSP servers recompute all diagnostics for all buffers
-- LSP Specification 3.17 defines a simpler way of doing this:
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_pullDiagnostics
-- However not all servers are caught up to 3.17, so use this hack instead
-- local function lsp_pull_diagnostics()
-- 	for _, client in ipairs(vim.lsp.get_active_clients()) do
-- 		for bufnr, _ in pairs(client.attached_buffers) do
-- 			client.notify('textDocument/diagnostic', {
-- 				textDocument = {
-- 					uri = vim.uri_from_bufnr(bufnr),
-- 				},
-- 			})
-- 		end
-- 	end
-- end
local function lsp_pull_diagnostics()
	for _, client in ipairs(vim.lsp.get_active_clients()) do
		for bufnr, _ in pairs(client.attached_buffers) do
			client.notify('textDocument/didChange', {
				textDocument = {
					uri = vim.uri_from_bufnr(bufnr),
					version = buf_versions[bufnr],
				},
				contentChanges = {
					text = get_full_text(bufnr)
				},
			})
		end
	end
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

M.relative_line_numbers = {}
function M.relative_line_numbers.isShown()
	return vim.o.relativenumber
end

function M.relative_line_numbers.show()
	set_all("relativenumber")
end

function M.relative_line_numbers.hide()
	set_all("norelativenumber")
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

	return require("gitsigns.config").config.signcolumn
end

function M.git_signs.show()
	local shown = M.git_signs.isShown()
	if shown == false then
		vim.cmd("silent! Gitsigns toggle_signs")
	end
end

function M.git_signs.hide()
	local shown = M.git_signs.isShown()
	if shown == true then
		vim.cmd("silent! Gitsigns toggle_signs")
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

M.strict = {}
function M.strict.isShown()
	return vim.g.ignore_strict_diagnostics ~= true
end

function M.strict.show()
	vim.g.ignore_strict_diagnostics = false

	lsp_pull_diagnostics()

	local lint_ok, _ = pcall(require, "lint")
    if not lint_ok then
        return
    end

	require("linting.lintCommon").update_strictness()
	vim.cmd("do User call_lint")
end

function M.strict.hide()
	vim.g.ignore_strict_diagnostics = true

	lsp_pull_diagnostics()

	local lint_ok, _ = pcall(require, "lint")
    if not lint_ok then
        return
    end

	require("linting.lintCommon").update_strictness()
	vim.cmd("do User call_lint")
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
		local saved_option = vim.g["HUD_" .. display_name]
		if saved_option == "true" then
			display.show()
		end
		if saved_option == "false" then
			display.hide()
		end
	end
end

return M
