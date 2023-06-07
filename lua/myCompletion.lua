-- This entire file gets run from myPlugins as part of the code completion config
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

require('myKeymaps.codeCompletion') -- Gives me CompletionMappings table

cmp.setup {
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = Completion_Mappings,
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
