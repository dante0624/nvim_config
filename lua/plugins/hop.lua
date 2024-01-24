local lazy_map = require("utils.map").lazy_map

return {
	{
		"smoka7/hop.nvim",
		tag = "v2.3.2",
		keys = lazy_map({
			{ "<C-k>", "<CMD>HopLineStartBC<CR>" },
			{ "<C-j>", "<CMD>HopLineStartAC<CR>" },
			{ "<C-l>", "<CMD>HopChar2<CR>" },
		}),
		opts = {},
	},
}
