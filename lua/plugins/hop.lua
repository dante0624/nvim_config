local lazy_map = require("utils.map").lazy_map

return {
	{
		"smoka7/hop.nvim",
		tag = "v2.3.2",
        -- Use semicolon because this plugin is about the home row
		keys = lazy_map({
			{ "<leader>;k", "<CMD>HopLineStartBC<CR>" },
			{ "<leader>;j", "<CMD>HopLineStartAC<CR>" },
			{ ";", "<CMD>HopChar2<CR>" },
		}),
		opts = {},
	},
}
