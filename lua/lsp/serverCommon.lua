local showTable = require("utils.showTable")

local M = {}

-- Sets up Diganostic signs, diagnostic config, and lsp handlers
-- Also defines a lua function that can help with debugging clients
function M.setup()
	vim.diagnostic.config({
		severity_sort = true,
		float = {
			border = "rounded",
			source = true,
			header = "",
			prefix = "",
		},
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = "",
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.INFO] = "",
				[vim.diagnostic.severity.HINT] = "󰌵",
			},
		},
	})

	-- Go up or down (k and j) the list of diagnostics
	vim.keymap.set("n", "<leader>sk", function()
		vim.diagnostic.jump({
			count = -1,
			float = true,
			wrap = true,
		})
	end)
	vim.keymap.set("n", "<leader>sj", function()
		vim.diagnostic.jump({
			count = 1,
			float = true,
			wrap = true,
		})
	end)
	vim.keymap.set("n", "<leader>so", vim.diagnostic.open_float)

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

		showTable(vim.lsp.get_clients(), "((Lsp Info))", ignored_keys)
	end
end

--- Key is the client_id, value is all the diagnostic info for that client.
--- @type table<integer, ClientDiagnosticTracker>
local diagnostics_tracker = {}

--- @class ClientDiagnosticTracker
--- @field diagnostic_filters DiagnosticFilters
--- @field bufnr_to_unfiltered_diagnostics_info table<integer, BufferDiagnosticsInfo>

--- @class BufferDiagnosticsInfo
--- @field diagnostic_params lsp.PublishDiagnosticsParams
--- @field ctx lsp.HandlerContext

--- Used to set up this tracker based on specific lsp settings
--- @param client_id integer
--- @param settings ServerConfig
local function set_up_tracker(client_id, settings)
	local non_filter = function(_) return true end

	local diagnostic_filters = settings.diagnostic_filters or {
		normal = non_filter,
		strict = non_filter,
	}

	diagnostics_tracker[client_id] = {
		diagnostic_filters = diagnostic_filters,
		bufnr_to_unfiltered_diagnostics_info = {},
	}
end

--- @param client_tracker ClientDiagnosticTracker
--- @return fun(diagnostic: lsp.Diagnostic):boolean
local function choose_filter(client_tracker)
	if vim.g.ignore_strict_diagnostics == true then
		return client_tracker.diagnostic_filters.normal
	end

	return client_tracker.diagnostic_filters.strict
end

--- This will pull data from the tracker, apply the filter, and then
--- publish the filtered diagnostics as if they came from the LSP server
--- @param client_id integer
--- @param bufnr integer
local function publish_tracker_diagnostics(client_id, bufnr)
	local client_tracker = diagnostics_tracker[client_id]
	local unfiltered_diagnostics_info = client_tracker.bufnr_to_unfiltered_diagnostics_info[bufnr]
	local filter = choose_filter(client_tracker)

	local filtered_diagnostics = vim.tbl_filter(filter, unfiltered_diagnostics_info.diagnostic_params.diagnostics)
	local filtered_diagnostics_params = vim.deepcopy(unfiltered_diagnostics_info.diagnostic_params)
	filtered_diagnostics_params.diagnostics = filtered_diagnostics

	vim.lsp.diagnostic.on_publish_diagnostics(
		nil,
		filtered_diagnostics_params,
		unfiltered_diagnostics_info.ctx
	)
end

--- Custom, overwritten handler for publishing diagnostics that allows
--- for client-side filtering.
--- See https://neovim.io/doc/user/lsp.html#lsp-handler
--- @param _ table? Error info dict, or `nil` if the request completed. 
--- @param diagnostic_params lsp.PublishDiagnosticsParams
--- @param ctx lsp.HandlerContext
local function custom_diagnostic_handler(_, diagnostic_params, ctx)
	local client_id = ctx.client_id
	local bufnr = vim.uri_to_bufnr(diagnostic_params.uri)
	diagnostics_tracker[client_id].bufnr_to_unfiltered_diagnostics_info[bufnr] = {
		diagnostic_params = diagnostic_params,
		ctx = ctx,
	}
	publish_tracker_diagnostics(client_id, bufnr)
end

local publish_diagnostics_handler_overwrite = {
	["textDocument/publishDiagnostics"] = custom_diagnostic_handler,
}

-- Loop over all clients and buffers publishing all filtered diagnostics
function M.refresh_diagnostics()
	for client_id, _ in pairs(diagnostics_tracker) do
		for bufnr, _ in pairs(diagnostics_tracker[client_id].bufnr_to_unfiltered_diagnostics_info) do
			publish_tracker_diagnostics(client_id, bufnr)
		end
	end
end

--- Language servers require each project to have a `root` in order to
--- provide features that require cross-file indexing.
---
---	Some servers support not passing a root directory as a proxy for single
---	file mode under which cross-file features may be degraded. 
---
---	This information came from the lspconfig doc at:
---	https://github.com/neovim/nvim-lspconfig/blob/b1a11b042d015df5b8f7f33aa026e501b639c649/doc/lspconfig.txt#L430
--- @param supports_single_file_mode boolean true if the server supports this feature.
--- @param root_dir string the root directory of the project, or the directory of a single file.
--- @param single_file boolean true if the root_dir is not part of a project.
--- @return string? language_server_root_arg
local function resolve_lsp_root_arg(supports_single_file_mode, root_dir, single_file)
	if supports_single_file_mode and single_file then
		return nil
	end

	return root_dir
end

--- By default, just overwrite "textDocument/publishDiagnostics"
--- Can also overwrite more handlers on a per-lsp basis
--- @param server_specific_handler_overwrites table<string,function>
--- @return table<string,function>
local function resolve_lsp_handler_overwrites(server_specific_handler_overwrites)
	if server_specific_handler_overwrites == nil then
		return publish_diagnostics_handler_overwrite
	end

	return vim.tbl_extend('error', publish_diagnostics_handler_overwrite, server_specific_handler_overwrites)
end

--- Attaches to an existing client if the name and root directory match.
---
--- If no match is found, then it creates and attaches to a new client.
--- First, finds the configuration for this new client in a separate file.
--- @param config_name string config file name to use for new clients.
--- @param root_dir string the root directory of the project, or the directory of a single file.
--- @param single_file boolean true if the root_dir is not part of a project.
--- @return integer client_id the client_id of the attached or new client.
function M.start_or_attach(config_name, root_dir, single_file)
	--- @type ServerConfig
	local settings = require("lsp.serverSpecific." .. config_name)(root_dir)

	local resolved_root_dir = resolve_lsp_root_arg(settings.single_file_support, root_dir, single_file)

	-- Trying to attach to active clients
	-- If sucessful, attach and then return early
	for _, client_opts in ipairs(vim.lsp.get_clients()) do
		local client_id = client_opts.id
		local client_name = client_opts.config.name
		local client_root = client_opts.config.root_dir
		if client_name == config_name and client_root == resolved_root_dir then
			vim.lsp.buf_attach_client(0, client_id)
			return client_id
		end
	end

	local client_id = vim.lsp.start({
		name = config_name,
		cmd = settings.cmd,
		root_dir = resolved_root_dir,
		init_options = settings.init_options,
		settings = settings.post_init_settings,
		on_attach = function(_, bufnr)
			local function lsp_map(mode, lhs, rhs, opts)
				local options = { buffer = bufnr }
				if opts then
					options = vim.tbl_extend("force", options, opts)
				end

				vim.keymap.set(mode, lhs, rhs, options)
			end

			-- The beautiful keymaps
			-- "s" for (language) "Server"
			lsp_map("n", "gd", vim.lsp.buf.definition)
			lsp_map("n", "gD", vim.lsp.buf.type_definition)
			lsp_map("n", "gr", vim.lsp.buf.references)
			lsp_map("", "<leader>sa", vim.lsp.buf.code_action)
			lsp_map("n", "<leader>ss", vim.lsp.buf.document_symbol)
			lsp_map("", "<leader>sf", vim.lsp.buf.format)
			lsp_map("n", "<leader>sh", function()
				vim.lsp.buf.hover({ border = 'rounded' })
			end)
			lsp_map("n", "<leader>sr", vim.lsp.buf.rename)
			lsp_map("n", "<leader>sw", vim.lsp.buf.workspace_symbol)
		end,
		capabilities = vim.tbl_deep_extend(
			'keep',
			require("cmp_nvim_lsp").default_capabilities(),
			vim.lsp.protocol.make_client_capabilities()
		),
		handlers = resolve_lsp_handler_overwrites(settings.server_to_client_handlers),
	})
	assert(client_id, "Could not start LSP")
	set_up_tracker(client_id, settings)

	return client_id
end

return M
