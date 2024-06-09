local refresh_diagnostics = require('lsp.serverCommon').refresh_diagnostics

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

    repeat_buffers
        True or false. Indicates if a show() / hide() function
        must be repeated in all open buffers to work.
        For example, vim.opt.number = true must be repeated

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
M.header.repeat_buffers = false

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
M.footer.repeat_buffers = false

M.line_numbers = {}
function M.line_numbers.isShown()
	return vim.o.number
end

function M.line_numbers.show()
    vim.opt.number = true
end

function M.line_numbers.hide()
	vim.opt.number = false
end
M.line_numbers.repeat_buffers = true

M.relative_line_numbers = {}
function M.relative_line_numbers.isShown()
	return vim.o.relativenumber
end

function M.relative_line_numbers.show()
	vim.opt.relativenumber = true
end

function M.relative_line_numbers.hide()
    vim.opt.relativenumber = false
end
M.relative_line_numbers.repeat_buffers = true

M.color_column = {}
function M.color_column.isShown()
	return vim.o.colorcolumn == "80"
end

function M.color_column.show()
    vim.opt.colorcolumn = "80"
end

function M.color_column.hide()
    vim.opt.colorcolumn = "0"
end
M.color_column.repeat_buffers = true

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
M.git_signs.repeat_buffers = false

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
M.diagnostics.repeat_buffers = false

M.strict = {}
function M.strict.isShown()
	return vim.g.ignore_strict_diagnostics ~= true
end

function M.strict.show()
	vim.g.ignore_strict_diagnostics = false

	refresh_diagnostics()

	local lint_ok, _ = pcall(require, "lint")
    if not lint_ok then
        return
    end

	require("linting.lintCommon").update_strictness()
	vim.cmd("do User call_lint")
end

function M.strict.hide()
	vim.g.ignore_strict_diagnostics = true

	refresh_diagnostics()

	local lint_ok, _ = pcall(require, "lint")
    if not lint_ok then
        return
    end

	require("linting.lintCommon").update_strictness()
	vim.cmd("do User call_lint")
end
M.strict.repeat_buffers = false

return M
