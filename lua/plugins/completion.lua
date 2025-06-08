local map = require("utils.map").map

return {
	{
		"hrsh7th/nvim-cmp",

		-- Use this commit until a newer tag drops
		commit = "b5311ab3ed9c846b585c0c15b7559be131ec4be9",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- This line actually gives me snippets
			require("luasnip/loaders/from_vscode").lazy_load()

			map({ "i", "s", }, "<C-h>", function()
				if luasnip.jumpable() then
					luasnip.jump(-1)
				else
					local current_cursor_col = vim.fn.getcurpos()[3]
					vim.fn.cursor(0, current_cursor_col - 1)
				end
			end)
			map({ "i", "s", }, "<C-l>", function()
				if luasnip.jumpable() then
					luasnip.jump(1)
				else
					local current_cursor_col = vim.fn.getcurpos()[3]
					vim.fn.cursor(0, current_cursor_col + 1)
				end

			end)

			-- The icons we will use for code completion
			-- find more here: https://www.nerdfonts.com/cheat-sheet
			local kind_icons = {
				Text = "󰬴",
				Method = "m",
				Function = "󰊕",
				Constructor = "",
				Field = "",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "",
				Unit = "",
				Value = "",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "",
				Event = "",
				Operator = "",
				TypeParameter = "󰊄",
			}
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),

                    -- Meant to mimic the commandline <C-r> for backward search and <C-s> for forward search
					['<C-r>'] = cmp.mapping.scroll_docs(-4),
					['<C-s>'] = cmp.mapping.scroll_docs(4),

					["<C-a>"] = cmp.mapping(function()
						if cmp.visible() then
							cmp.abort()
						else
							cmp.complete()
						end
					end, { "i", "s" }),

					-- Need to select option with tab before hitting enter
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				},
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						vim_item.kind =
							string.format("%s", kind_icons[vim_item.kind])
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						})[entry.source.name]
						return vim_item
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},
				window = {
					documentation = cmp.config.window.bordered(),
				},
				experimental = {
					ghost_text = false,
					native_menu = false,
				},
			})
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		tag = "v2.0.0",
		lazy = true,
	},

	-- Looks like the author of these, especially cmp-nvim-lua, is working
	-- on removing deprecated function usage right now. Just need to wait.
	{
		"hrsh7th/cmp-buffer",
		commit = "3022dbc9166796b644a841a02de8dd1cc1d311fa",
		lazy = true,
	},
	{
		"hrsh7th/cmp-path",
		commit = "91ff86cd9c29299a64f968ebb45846c485725f23",
		lazy = true,
	},
	{
		"hrsh7th/cmp-nvim-lsp",
		commit = "78924d1d677b29b3d1fe429864185341724ee5a2",
		lazy = true,
	},
	{
		"saadparwaiz1/cmp_luasnip",
		commit = "18095520391186d634a0045dacaa346291096566",
		lazy = true,
	},
	{
		"rafamadriz/friendly-snippets",
		commit = "0368bee1cecaf3c58d436524234baad4c0e0b8cb",
		lazy = true,
	},
}
