local configs_ignore = require("utils.paths").Lint_Ignore

local settings = require("linting.misc").copy_default("stylelint")

-- Modify this one argument to point to a new linter config
settings.args[2] = configs_ignore .. "stylelintrc.json"
return settings


