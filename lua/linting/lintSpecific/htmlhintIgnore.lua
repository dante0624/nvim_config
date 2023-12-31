local settings = require("linting.misc").copy_default("htmlhint")

-- Attribute rules first
settings.args[5] = "attr-no-duplication,attr-unsafe-chars,"
	.. "attr-value-not-empty,alt-require,input-requires-label,"
	--Tags
	.. "tag-pair,tagname-specialchars,src-not-empty,"
	--ID
	.. "id-unique,"
	-- Formatting
	.. "spec-char-escape"

return settings
