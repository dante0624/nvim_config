local paths = require("utils.paths")
local showTable = require("utils.showTable")

local M = {}

-- When LSP is attached to a buffer, this sets the keymaps for that buffer
function M.on_attach(_, bufnr)
	-- Helper function to be less repetitive
	local function lsp_map(mode, lhs, rhs, opts)
		local options = { buffer = bufnr }
		if opts then
			options = vim.tbl_extend("force", options, opts)
		end

		vim.keymap.set(mode, lhs, rhs, options)
	end

	-- The beautiful keymaps
	lsp_map("n", "gd", vim.lsp.buf.definition)
	lsp_map("n", "gD", vim.lsp.buf.type_definition)
	lsp_map("n", "gr", vim.lsp.buf.references)
	lsp_map("n", "<leader>lh", vim.lsp.buf.hover)
	lsp_map("n", "<leader>la", vim.lsp.buf.code_action)
	lsp_map("n", "<leader>lr", vim.lsp.buf.rename)
	lsp_map("n", "<leader>lf", vim.lsp.buf.format)
end

-- Sets up Diganostic signs, diagnostic config, and lsp handlers
-- Also defines a lua function that can help with debugging clients
function M.setup()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
		{ name = "DiagnosticSignHint", text = "󰌵" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(
			sign.name,
			{ texthl = sign.name, text = sign.text, numhl = "" }
		)
	end

	vim.diagnostic.config({
		-- disable virtual text
		virtual_text = false,
		severity_sort = true,
		float = {
			-- focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	})

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
		vim.lsp.handlers.hover,
		{ border = "rounded" }
	)

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
		vim.lsp.handlers.signature_help,
		{ border = "rounded" }
	)

	-- Go up or down (k and j) the list of diagnostics
	-- di for diagnostic inspect
	vim.keymap.set("n", "<leader>dk", function()
		vim.diagnostic.goto_prev({ border = "rounded" })
	end)
	vim.keymap.set("n", "<leader>dj", function()
		vim.diagnostic.goto_next({ border = "rounded" })
	end)
	vim.keymap.set("n", "<leader>di", vim.diagnostic.open_float)


	function LspInfo(all_keys)
		if all_keys == nil then
			all_keys = false
		end

		local ignored_keys
		if all_keys then
			ignored_keys = {}
		else
			ignored_keys = {
				"capabilities",
				"server_capabilities",
				"rpc",
				"get_language_id",
				"on_attach",
				"offset_encoding",
				"request_sync",
				"_on_attach",
				"supports_method",
				"stop",
				"notify",
				"request",
				"cancel_request",
				"is_stopped",
				"messages",
				"on_init",
				"requests",
				"commands",
				"handlers",
				"flags",
			}
		end

		showTable(vim.lsp.get_active_clients(), "((Lsp Info))", ignored_keys)
	end
end

-- Attaches to an existing client if the name and root directory match
-- If no match, it starts a new LSP client and attaches to that
-- Returns true for "single_file_mode"
-- Returns false otherwise
function M.start_or_attach(mason_name, cmd_extra, root_files)
	if cmd_extra == nil then cmd_extra = {} end
	if root_files == nil then root_files = { '.git' } end

	-- Check for a root directory and set single_file_mode accordingly
	local root_dir = vim.fs.dirname(
		vim.fs.find(root_files, { upward = true })[1]
	)

	local single_file_mode
	if root_dir == nil then
		single_file_mode = true

	 	-- The folder that the current buffer is in
		root_dir = vim.fn.expand('%:p:h')
	else
		single_file_mode = false
	end

	root_dir = vim.fn.fnamemodify(root_dir, ":p")

	-- Lua hotifx, make the root dir start at lua/ rather than before it
	if mason_name == "lua-language-server" then
		for name, type in vim.fs.dir(root_dir) do
			if name == "lua" and type == "directory" then
				root_dir = root_dir .. "lua/"
				break
			end
		end
	end


	-- Trying to attach to active clients
	-- If sucessful, attach and then return early
	for client_id, client_opts in pairs(vim.lsp.get_active_clients()) do
		local client_name = client_opts.config.name
		local client_root = client_opts.config.root_dir
		if client_name == mason_name and client_root == root_dir then
			vim.lsp.buf_attach_client(0, client_id)
			return single_file_mode
		end
	end

	local cmd = { paths.Mason_Bin .. mason_name }
	for _, v in ipairs(cmd_extra) do
		table.insert(cmd, v)
	end

	-- All of these can be overwritten by language specific settings
	local init_options = {}
	local pre_attach_settings = {}
	local on_attach = M.on_attach

	local settings_ok, settings = pcall(
		require,
		"lsp.languageSpecific." .. mason_name
	)
	if settings_ok then
		if settings.init_options ~= nil then
			init_options = settings.init_options
		end
		if settings.pre_attach_settings ~= nil then
			pre_attach_settings = settings.pre_attach_settings
		end
		if settings.post_attach_settings ~= nil then
			on_attach = function(_, bufnr)
				M.on_attach(_, bufnr)
				vim.lsp.buf_notify(
					bufnr,
					"workspace/didChangeConfiguration",
					settings.post_attach_settings
				)
			end
		end
	end

	vim.lsp.start({
		name = mason_name,
		cmd = cmd,
		root_dir = root_dir,
		init_options = init_options,
		settings = pre_attach_settings,
		on_attach = on_attach,
		capabilities = require("cmp_nvim_lsp").default_capabilities(),

	})

	return single_file_mode
end

return M
