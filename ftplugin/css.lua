require("lsp.languageCommon").start_or_attach("vscode-css-language-server")
require("linting.lintCommon").setup_linters({"stylelint"})

