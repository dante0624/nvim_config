require('myKeymaps.telescopeHelpers')
local actions = require "telescope.actions"
local Map = require("utils.map").Map

-- Keybinds for a regular buffer
Map('', '<leader>f', '<Cmd>Telescope find_files<CR>')
Map('', '<leader>g', '<Cmd>Telescope live_grep<CR>')

-- Keybinds for within Telescope
My_Telescope_Keymaps = {
	i = {
        ["<C-c>"] = actions.close,

        ["<C-v>"] = Stop_Insert(Custom_Actions.multi_selection_open_vertical),
        ["<C-x>"] = Stop_Insert(Custom_Actions.multi_selection_open_horizontal),
        ["<CR>"]  = Stop_Insert(Custom_Actions.multi_selection_open),

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

		["<C-l>"] = actions.open_qflist,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        -- ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        -- ["<C-l>"] = actions.complete_tag,

        ["<C-/>"] = actions.which_key,
      },

      n = {
        ["q"] = actions.close,

        ["v"] = Custom_Actions.multi_selection_open_vertical,
        ["x"] = Custom_Actions.multi_selection_open_horizontal,
        ["<CR>"] = Custom_Actions.multi_selection_open,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
        ["J"] = actions.results_scrolling_up,
        ["K"] = actions.results_scrolling_down,
        ["M"] = actions.move_to_middle,
        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,

        ["n"] = actions.cycle_history_next,
        ["p"] = actions.cycle_history_prev,

        ["u"] = actions.preview_scrolling_up,
        ["d"] = actions.preview_scrolling_down,

		["l"] = actions.open_qflist,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        -- ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

        ["?"] = actions.which_key,
	}
}

