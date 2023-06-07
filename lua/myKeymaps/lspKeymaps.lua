-- This gets imported by lsp.handlers and becomes part of 'on_attach' function
-- That then gets added to all lsps within lsp.init
function Lsp_Keymaps(bufnr)

	-- Helper function to be less repetitive
	local function lsp_map(mode, lhs, rhs, opts)
		local options = { noremap = true, silent = true, }
		if opts then
			options = vim.tbl_extend("force", options, opts)
		end

		-- This line differs from the regular utils.map function
		vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, options)
	end

	-- The beautiful keymaps
	lsp_map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
	lsp_map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
	lsp_map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
	lsp_map("n", "<leader>ho", "<cmd>lua vim.lsp.buf.hover()<CR>") -- ho for hover
	lsp_map("n", "<leader>l", "<cmd>lua vim.diagnostic.open_float()<CR>")  -- l for line help
	lsp_map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
	lsp_map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")

	-- Go up or down (k and j) the list of diagnostics
	lsp_map("n", "<leader>dk", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>')
	lsp_map("n", "<leader>dj", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>')
end

