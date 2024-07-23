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

--[[ First key of this table is the client_id
Next are 3 possible keys:
	normal_filter
		function(diagnostic) -> boolean
		Return true if that diagnostic should be shown in "normal mode"
	strict_filter
		function(diagnostic) -> boolean
		Return true if that diagnostic should be shown in "strict mode"
	bufnrs
		Maps to a sub table, where each key is a bufnr
		Each of these bufnrs maps to all (unfiltered) diagnostics
		for that client and bufnr specifically ]]
local diagnostics_tracker = {}

-- Used to set up this tracker based on specific lsp settings
-- These are found as languageSpecific settings
local function set_up_tracker(client_id, settings)
	local non_filter = function(_) return true end

	-- Ignore different diagnostic in strict vs  mode
	local diagnostic_filters = settings.diagnostic_filters or {}
	local normal_filter = diagnostic_filters.normal or non_filter
	local strict_filter = diagnostic_filters.strict or non_filter

	-- Bufnrs will be added as diagnostics are published
	diagnostics_tracker[client_id] = {
		normal_filter = normal_filter,
		strict_filter = strict_filter,
		bufnrs = {},
	}
end

-- This will pull data from the tracker, apply the filter, and then
-- publish the filtered diagnostics as if they came from the LSP server
local function publish_tracker_diagnostics(client_id, bufnr)
	local client_tracker = diagnostics_tracker[client_id]

	local filter
	if vim.g.ignore_strict_diagnostics == true then
		filter = client_tracker.normal_filter
	else
		filter = client_tracker.strict_filter
	end

	local filtered_diagnostics = {}
	for _, diagnostic in ipairs(client_tracker.bufnrs[bufnr]) do
		if filter(diagnostic) then
			table.insert(filtered_diagnostics, diagnostic)
		end
	end

	local result = {
		uri = vim.uri_from_bufnr(bufnr),
		diagnostics = filtered_diagnostics,
	}

	local ctx = { client_id = client_id }

	vim.lsp.diagnostic.on_publish_diagnostics(nil, result, ctx, nil)
end

-- Loop over all clients and buffers publishing all filtered diagnostics
function M.refresh_diagnostics()
	for client_id, _ in pairs(diagnostics_tracker) do
		for bufnr, _ in pairs(diagnostics_tracker[client_id].bufnrs) do
			publish_tracker_diagnostics(client_id, bufnr)
		end
	end
end

-- Attaches to an existing client if the name and root directory match
-- If no match is found, then it creates and attaches to a new client
-- Returns the client_id in either case
function M.start_or_attach(config_name, root_dir, single_file)
	if single_file == nil then
		single_file = false
	end

	-- Trying to attach to active clients
	-- If sucessful, attach and then return early
	for client_id, client_opts in pairs(vim.lsp.get_active_clients()) do
		local client_name = client_opts.config.name
		local client_root = client_opts.config.root_dir
		if client_name == config_name and client_root == root_dir then
			vim.lsp.buf_attach_client(0, client_id)
			return client_id
		end
	end

	-- All of these can be overwritten by language specific settings
	local init_options = {}
	local pre_attach_settings = {}
	local on_attach = M.on_attach_keymaps

	local settings = require("lsp.serverSpecific." .. config_name)

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

	--[[ Language servers require each project to have a `root` in order to
	provide features that require cross-file indexing.

	Some servers support not passing a root directory as a proxy for single
	file mode under which cross-file features may be degraded. 

	This information came from the lspconfig doc at:
	https://github.com/neovim/nvim-lspconfig/blob/b1a11b042d015df5b8f7f33aa026e501b639c649/doc/lspconfig.txt#L430
	]]
	if settings.single_file_support and single_file then
		root_dir = nil
	end

	local capabilities = vim.tbl_deep_extend(
		'keep',
		require("cmp_nvim_lsp").default_capabilities(),
		vim.lsp.protocol.make_client_capabilities()
	)

	local client_id = vim.lsp.start({
		name = config_name,
		cmd = settings.cmd,
		root_dir = root_dir,
		settings = pre_attach_settings,
		init_options = init_options,
		on_attach = on_attach,
		capabilities = capabilities,
		handlers = {
			["textDocument/publishDiagnostics"] = function(_, result, ctx, _)
				local client_id = ctx.client_id
				local bufnr = vim.uri_to_bufnr(result.uri)
				local diagnostics = result.diagnostics

				diagnostics_tracker[client_id].bufnrs[bufnr] = diagnostics

				publish_tracker_diagnostics(client_id, bufnr)
			end,
		},
	})

	set_up_tracker(client_id, settings)

	return client_id
end

return M
