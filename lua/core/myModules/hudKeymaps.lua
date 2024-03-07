local map = require("utils.map").map

local hud = require("core.myModules.headsUpDisplay")

local M = {}

-- Prefix with d for HeadsUpDisplay
map("", "<Leader>dh", hud.header.toggle)
map("", "<Leader>df", hud.footer.toggle)
map("", "<Leader>dl", hud.line_numbers.toggle)
map("", "<Leader>dr", hud.relative_line_numbers.toggle)
map("", "<Leader>dc", hud.color_column.toggle)
map("", "<Leader>dg", hud.git_signs.toggle)
map("", "<Leader>dd", hud.diagnostics.toggle)
map("", "<Leader>ds", hud.strict.toggle)

-- These can be used to set "favorite" HUD settings
-- Especially useful when set to a keymap
local function onlyShow(tbl)
	-- First hide everything
	for _, display in pairs(hud) do
		display.hide()
	end

	for _, mode_name in ipairs(tbl) do
		hud[mode_name].show()
	end
end
local function onlyHide(tbl)
	-- First show everything
	for _, mode in pairs(hud) do
		mode.show()
	end

	for _, mode_name in ipairs(tbl) do
		hud[mode_name].hide()
	end
end

-- Shows all displays
map("", "<Leader>da", function()
	onlyHide({})
end)

-- Show no displays
map("", "<Leader>dq", function()
	onlyShow({})
end)

-- My own verion of "zen mode".
-- I think its important to still show diagnostics
map("", "<Leader>dz", function()
	onlyShow({ "diagnostics" })
end)

-- Get rid of the header because "The Primagen" (p) suggests not using it
-- Use this when trying to immediately jump to buffers with <Control> {a-g}
map("", "<Leader>dp", function()
	onlyHide({ "header", "relative_line_numbers" })
end)

function M.default_display()
    onlyHide({ "relative_line_numbers", "strict" })
end

map("", "<Leader>do", M.default_display)

return M
