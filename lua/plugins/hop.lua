local default_key_map_modes = require("utils.map").default_key_map_modes
local alpabetical_key_map_modes = require("utils.map").alpabetical_key_map_modes

return {
	{
		"smoka7/hop.nvim",
		tag = "v2.3.2",
        -- Use semicolon because this plugin is about the home row
		keys = {
			{ "<leader>;k", "<CMD>HopLineStartBC<CR>", mode = default_key_map_modes },
			{ "<leader>;j", "<CMD>HopLineStartAC<CR>", mode = default_key_map_modes },
			{ ";", "<CMD>HopChar2<CR>", mode = alpabetical_key_map_modes },
		},
		opts = {},
	},
}
