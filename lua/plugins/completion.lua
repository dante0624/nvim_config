return {{
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
		'L3MON4D3/LuaSnip',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-nvim-lua',
		'saadparwaiz1/cmp_luasnip',
		'rafamadriz/friendly-snippets',
    },
	config = function()
		local cmp = require('cmp')
		local luasnip = require('luasnip')
		require("luasnip/loaders/from_vscode").lazy_load() -- This line actually gives me snippets

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

		local completion_mappings = {
			["<C-k>"] = cmp.mapping.select_prev_item(),
			["<C-j>"] = cmp.mapping.select_next_item(),
			["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
			["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
			["<C-a>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
			["<C-y>"] = cmp.config.disable, -- Not sure why we disable this
			["<C-l>"] = cmp.mapping {
				i = cmp.mapping.abort(),
				c = cmp.mapping.close(),
			},

			-- True causes enter to autoselect the first item in a list
			-- False means you have to hover over the item first (with TAB usually)
			-- I like false more, because it makes every selection more explicit
			["<CR>"] = cmp.mapping.confirm { select = false },

			-- Idea is to make Tab do many things based on context
			-- It is known as "superTab"
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expandable() then
					luasnip.expand()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s", }),

			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s", }),
		}
		cmp.setup {
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = completion_mappings,
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
					vim_item.menu = ({
						nvim_lua = "[Nvim Lua]",
						nvim_lsp = "[LSP]",
						luasnip = "[Snippet]",
						buffer = "[Buffer]",
						path = "[Path]",
					})[entry.source.name]
					return vim_item
				end,
			},
			sources = {
				{ name = "nvim_lua" },
				{ name = "nvim_lsp"},
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
		}
	end,
}}
