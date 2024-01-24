local showTable = require("utils.showTable")
local M = {}

-- When LSP is attached to a buffer, this sets the keymaps for that buffer
function M.on_attach_keymaps(_, bufnr)
	-- Helper function to be less repetitive
	local function lsp_map(mode, lhs, rhs, opts)
		local options = { buffer = bufnr }
		if opts then
			options = vim.tbl_extend("force", options, opts)
		end

		vim.keymap.set(mode, lhs, rhs, options)
	end

	-- The beautiful keymaps
    -- "a" for 'Attached' or 'Action'
	lsp_map("n", "gd", vim.lsp.buf.definition)
	lsp_map("n", "gD", vim.lsp.buf.type_definition)
	lsp_map("n", "gr", vim.lsp.buf.references)
	lsp_map("", "<leader>aa", vim.lsp.buf.code_action)
	lsp_map("n", "<leader>as", vim.lsp.buf.document_symbol)
	lsp_map("", "<leader>af", vim.lsp.buf.format)
	lsp_map("n", "<leader>ah", vim.lsp.buf.hover)
	lsp_map("n", "<leader>ar", vim.lsp.buf.rename)
	lsp_map("n", "<leader>aw", vim.lsp.buf.workspace_symbol)
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

	vim.lsp.handlers["textDocument/hover"] =
		vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

	vim.lsp.handlers["textDocument/signatureHelp"] =
		vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

	-- Go up or down (k and j) the list of diagnostics
	vim.keymap.set("n", "<leader>ak", function()
		vim.diagnostic.goto_prev({ border = "rounded" })
	end)
	vim.keymap.set("n", "<leader>aj", function()
		vim.diagnostic.goto_next({ border = "rounded" })
	end)
	vim.keymap.set("n", "<leader>ao", vim.diagnostic.open_float)

	function LspInfo(all_keys)
		if all_keys == nil then
			all_keys = false
		end

		local ignored_keys
		if all_keys then
			ignored_keys = {}
		else
			ignored_keys = {
				-- "capabilities",
				-- "server_capabilities",
				"completionItem",
				"triggerCharacters",
				"tokenModifiers",
				"tokenTypes",
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
function M.start_or_attach(config_name, root_files)
	if root_files == nil then
		root_files = { ".git" }
	end

	-- Check for a root directory and set single_file_mode accordingly
	local root_dir =
		vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1])

	local single_file_mode
	if root_dir == nil then
		single_file_mode = true

		-- The folder that the current buffer is in
		root_dir = vim.fn.expand("%:p:h")
	else
		single_file_mode = false
	end

	root_dir = vim.fn.fnamemodify(root_dir, ":p")

	-- Lua hotifx, make the root dir start at lua/ rather than before it
	if config_name == "lua-language-server" then
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
		if client_name == config_name and client_root == root_dir then
			vim.lsp.buf_attach_client(0, client_id)
			return single_file_mode
		end
	end

	-- All of these can be overwritten by language specific settings
	local init_options = {}
	local pre_attach_settings = {}
	local on_attach = M.on_attach_keymaps

	local settings = require("lsp.languageSpecific." .. config_name)

	assert(settings.cmd, "LSP configuration needs a cmd attribute")

	if settings.init_options ~= nil then
		init_options = settings.init_options
	end
	if settings.pre_attach_settings ~= nil then
		pre_attach_settings = settings.pre_attach_settings
	end
	if settings.post_attach_settings ~= nil then
		on_attach = function(_, bufnr)
			M.on_attach_keymaps(_, bufnr)
			vim.lsp.buf_notify(
				bufnr,
				"workspace/didChangeConfiguration",
				settings.post_attach_settings
			)
		end
	end

	vim.lsp.start({
		name = config_name,
		cmd = settings.cmd,
		root_dir = root_dir,
		settings = pre_attach_settings,
		init_options = init_options,
		on_attach = on_attach,
		capabilities = require("cmp_nvim_lsp").default_capabilities(),
	})

	return single_file_mode
end

return M
