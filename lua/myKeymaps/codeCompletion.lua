-- Gets used by myCompletion, which then gets used by myPlugins
local cmp = require('cmp')
local luasnip = require('luasnip')

Completion_Mappings = {
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

