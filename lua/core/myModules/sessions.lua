local default_display = require("core.myModules.hudKeymaps").default_display

-- If vim was called with any arguments, set the default hud and then return
if vim.v.argv[3] ~= nil then
    default_display()
	return
end

local hud = require("core.myModules.headsUpDisplay")
local paths = require("utils.paths")

-- Session loads and restores should only depend on the initial cwd
local initial_directory = vim.fn.getcwd()

local session_file_name = paths.serialize_path(initial_directory) .. ".vim"
local full_session_path = paths.Sessions .. session_file_name

-- Add in needed escape characters
local source_file = vim.fn.fnameescape(full_session_path)

-- Make sure the the desired directory exists
vim.fn.mkdir(paths.Sessions, "p")

-- Globals are needed for extra things:
-- Tabline orderings
-- The state of the HUD
vim.opt.sessionoptions:append("globals")

local session_group = vim.api.nvim_create_augroup("sessions", { clear = true })
vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
	pattern = "*",
	group = session_group,

	callback = function()
		-- Save barbar order of buffers
		vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })

		-- Save the HUD state
		for _, display in pairs(hud) do
			display.save()
		end

		-- Actually save the session file
		-- Put all pre_save logic before this
		vim.cmd("mks! " .. source_file)
	end,
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
	pattern = "*",
	group = session_group,

	callback = function()
		-- If there is no session to restore, then return early
		if vim.fn.filereadable(full_session_path) == 0 then
            default_display()
			return
		end

		-- Actually restore the session file
		-- Put all post_restore logic after this
		vim.cmd("silent! source " .. source_file)

		-- Sometimes restoring the file messes with the cwd,
		-- set it back to what it should be
		local starting_buffer = vim.fn.bufnr()
		vim.cmd("silent! bufdo cd" .. initial_directory)
		vim.cmd("buffer " .. starting_buffer)

		-- Sometimes neo-tree will leave behind a buffer of itself,
		-- delete this if accidentally restored
		for _, buf in ipairs(vim.fn.getbufinfo()) do
			-- Lua uses % to escape characters with string.find
			if buf.name:find("neo%-tree filesystem") ~= nil then
				vim.cmd("bd! " .. buf.bufnr)
			end
		end

		-- Restore the HUD state
		for _, display in pairs(hud) do
			display.restore()
		end
	end,
	nested = true,
})
