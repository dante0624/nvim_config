local map = require("utils.map").map
local tables = require("utils.tables")

local hud = require("core.myModules.headsUpDisplay")

local M = {}

-- toggle some hud element using its element_name (key from the hud table)
local function toggle(element_name)
    local element = hud[element_name]
    local shown = element.is_shown()

    if shown == true then
        print("Hiding: " .. element_name)
		element:hide()
    elseif shown == false then
        print("Showing: " .. element_name)
		element:show()
    else
        print("Failed toggle call on: " .. element_name)
    end
end

-- Prefix with v, for how we "view" the screen
map("", "<Leader>vt", function() toggle("tabs") end)
map("", "<Leader>vl", function() toggle("line_numbers") end)
map("", "<Leader>vr", function() toggle("relative_line_numbers") end)
map("", "<Leader>vc", function() toggle("color_column") end)
map("", "<Leader>vg", function() toggle("git_signs") end)
map("", "<Leader>vb", function() toggle("buffer_sign_column") end)
map("", "<Leader>vd", function() toggle("diagnostics") end)
map("", "<Leader>vs", function() toggle("strict") end)

-- This function can be used to set "favorite" HUD settings
local function show_hide_batch(show_names, hide_names)
    -- Set all the singular ones
    for _, element_name in ipairs(show_names) do
        hud[element_name]:show()
    end
    for _, element_name in ipairs(hide_names) do
        hud[element_name]:hide()
    end
end

-- Convenience Functions that wrap show_hide_batch
local function onlyShow(show_names)
    local show_names_set = tables.array_to_set(show_names)
    local hide_names = {}
    for element_name, _ in pairs(hud) do
        if not show_names_set[element_name] then
            table.insert(hide_names, element_name)
        end
    end

    show_hide_batch(show_names, hide_names)
end
local function onlyHide(hide_names)
    local hide_names_set = tables.array_to_set(hide_names)
    local show_names = {}
    for element_names, _ in pairs(hud) do
        if not hide_names_set[element_names] then
            table.insert(show_names, element_names)
        end
    end

    show_hide_batch(show_names, hide_names)
end

-- Shows all displays
map("", "<Leader>va", function()
	print("Heads Up Display - Show All")
	onlyHide({})
end)

-- Show no displays
map("", "<Leader>vq", function()
	print("Heads Up Display - Hide All")
	onlyShow({})
end)

-- My own version of "zen mode".
-- For making changes to larger codebase that can be overwhelming
map("", "<Leader>vz", function()
	print("Heads Up Display - Zen Mode")
	onlyShow({ "diagnostics", "git_signs", "buffer_sign_column" })
end)

-- Publication Mode: Strict Diagnostics and the Color Column
map("", "<Leader>vp", function()
	onlyHide({ "relative_line_numbers", "buffer_sign_column" })
end)

function M.default_display()
	print("Heads Up Display - Default Hud")
	onlyHide({ "relative_line_numbers", "strict", "color_column", "buffer_sign_column" })
end

map("", "<Leader>vo", M.default_display)

return M
