--[[
We have a huge problem where if we open files through telescope,
it doesn't remember the folds. It misses the autocmd.
This is known about, as a flaw with telescope itself: 
	https://github.com/nvim-telescope/telescope.nvim/issues/1277
There are 3 fixes:
	1: Type :e whenever a new file opens after telescope
		:e reloads the buffer, and will cause the autocmd to hit
		Great backup option in case other ideas fail
	2: When using telescope, exit its insertion mode first (go to normal mode),
	and then choose the file.
		For some reason this works
		The bug does not happen from telescope's normal mode
	3: Automate solution 2, such that some insertion mode keymappings
	will first go to normal mode first and then execute.
		First, make use of :stopinsert
		Then execute a command that opens the file
		I found a solution online that does this
			Scroll down really far to see this answer
			https://github.com/nvim-telescope/telescope.nvim/issues/1048
			Also implements multi_open after selecting with TAB ]]

local actions = require "telescope.actions"

-- Some BS that lets you turn your simple functions into Telescope 'actions'
-- With this we can set keybinds to execute arbitrary functions
local transform_mod = require("telescope.actions.mt").transform_mod
--[[ Example code from the telescope docs
local mod = {}
mod.a1 = function(prompt_bufnr)
-- your code goes here
-- You can access the picker/global state
end

mod.a2 = function(prompt_bufnr)
-- your code goes here
end

mod = transform_mod(mod)

-- Now the following is possible. This means that actions a2 will be executed
-- after action a1. You can chain as many actions as you want.
local action = mod.a1 + mod.a2
action(bufnr) ]]

local action_state = require "telescope.actions.state"

-- Helper functions from github issues page
-- This was heavily modified by me to make grep work with multi_selection
local function multi_open(prompt_bufnr, method)
    local cmd_map = {
        vertical = "vsplit",
        horizontal = "split",
        default = "edit"
    }
    local picker = action_state.get_current_picker(prompt_bufnr)
    local multi_selection = picker:get_multi_selection()

    if #multi_selection >= 1 then
        require("telescope.pickers").on_close_prompt(prompt_bufnr)
        pcall(vim.api.nvim_set_current_win, picker.original_win_id)

		local cmd = cmd_map[method]
        for _, entry in ipairs(multi_selection) do
			local section = vim.fn.split(entry.value, ":")

			local filename = section[1]
			local row = tonumber(section[2]) -- Will be nil if doesn't exist
			local col = tonumber(section[3]) -- Will be nil if doesn't exist

            vim.cmd(string.format("%s %s", cmd, filename))

			if row and col then
				local ok, err_msg = pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
				if not ok then
					print("Failed to move to cursor:", err_msg, row, col)
				end
			end
        end
    else
        actions["select_" .. method](prompt_bufnr)
    end
end

Custom_Actions = transform_mod({
    multi_selection_open_vertical = function(prompt_bufnr)
        multi_open(prompt_bufnr, "vertical")
    end,
    multi_selection_open_horizontal = function(prompt_bufnr)
        multi_open(prompt_bufnr, "horizontal")
    end,
    multi_selection_open = function(prompt_bufnr)
        multi_open(prompt_bufnr, "default")
    end,
})

function Stop_Insert(callback)
    return function(prompt_bufnr)
        vim.cmd.stopinsert()
        vim.schedule(function()
            callback(prompt_bufnr)
        end)
    end
end

