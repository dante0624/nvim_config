local servers = {
	"lua_ls", -- Lua
	"pyright", -- Python
	-- "jdtls", -- Java has its own way of doing things
}

local installer_settings = {
	ui = {
		border = "none",
		icons = {
			package_installed = "◍",
			package_pending = "◍",
			package_uninstalled = "◍",
		},
	},
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
}

require("mason").setup(installer_settings)
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = true,
})

local lspconfig = require("lspconfig")

local opts = {}

local completion_capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_on_attach = require("lsp.handlers").on_attach

for _, server in pairs(servers) do
	opts = {
		on_attach = lsp_on_attach,
		capabilities = completion_capabilities,
	}

	server = vim.split(server, "@")[1]

	-- Adding language specific settings
	local require_ok, conf_opts = pcall(require, "lsp.language_specific." .. server)
	if require_ok then
		opts = vim.tbl_deep_extend("force", conf_opts, opts)
	end

	lspconfig[server].setup(opts)
end

require("lsp.handlers").setup()

