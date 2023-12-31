local lazy_map = require("utils.map").lazy_map

return {
	{
		"smoka7/hop.nvim",
		tag = "v2.3.2",
		keys = lazy_map({
			{ "<Leader>k", "<CMD>HopLineStartBC<CR>" },
			{ "<Leader>j", "<CMD>HopLineStartAC<CR>" },
			{ "<Leader>;", "<CMD>HopChar2<CR>" },
		}),
		opts = {},
	},
}
