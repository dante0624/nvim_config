require("lsp.languageCommon").start_or_attach("vscode-html-language-server")
require("linting.lintCommon").setup_linters({ "htmlhint" })
