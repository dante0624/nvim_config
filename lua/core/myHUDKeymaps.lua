local Map = require("utils.map").Map
local HUD = require("core.myHUD")

Map('', 'tk', HUD.toggle_header)
Map('', 'tj', HUD.toggle_footer)
Map('', 'tl', HUD.toggle_line_numbers)

-- This is the only keymap which explicitly requires a plugin to exist
-- So make sure that the plugin is instaled before setting the keymapping
local git_signs_installed, _ = pcall(require, 'gitsigns')
if git_signs_installed then
	Map('', 'th', HUD.toggle_git_signs)
end

