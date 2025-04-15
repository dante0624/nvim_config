--[[ TODO:
The plan for how to make this work:
	Don't call setup()
		I think this is only needed for making format on save work with :wq
	
	Save my own formatting settings and configs just like I did with nvimLint
	Set those configs using:
		require("conform").formatters.name = {
			inherit = false,
			command = "soemthing",
			args = { -- stuff },
			etc.
		}
	
	Keep track of which linters I have already configured by doing:
		local M.already_configured = {
			linter_name: true,
			other_name: true,
		}

		Can quickly check if we already configured something
	
	When I set the keymaps, they should invoke:
		require("conform").format({
			formatters = { -- List of strings }
			lsp_fallback = { true | false | "always" }
		}) ]]
return {
	{
		"stevearc/conform.nvim",
		tag = "v9.0.0",
		lazy = true,
	},
}
