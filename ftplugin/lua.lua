require("lsp.languageCommon").start_or_attach("lua-language-server")
require("formatting.formatCommon").setup_formatters({ "stylua" }, false)
