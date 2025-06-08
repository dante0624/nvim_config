local map = require("utils.map").map
local buf_do = require("utils.buffers").buf_do
local tables = require("utils.tables")

local hud = require("core.myModules.headsUpDisplay")

local M = {}

-- toggle some hud display using its display_name (key from the hud table)
local function toggle(display_name)
    local display = hud[display_name]
    local shown = display.isShown()
    local repeat_buffers = display.repeat_buffers

    if shown == true then
        print("Hiding: " .. display_name)
        if repeat_buffers then
            buf_do(display.hide)
        else
            display.hide()
        end
    elseif shown == false then
        print("Showing: " .. display_name)
        if repeat_buffers then
            buf_do(display.show)
        else
            display.show()
        end
    else
        print("Failed toggle call on: " .. display_name)
    end
end

-- Prefix with d for HeadsUpDisplay
map("", "<Leader>dt", function() toggle("tabs") end)
map("", "<Leader>dl", function() toggle("line_numbers") end)
map("", "<Leader>dr", function() toggle("relative_line_numbers") end)
map("", "<Leader>dc", function() toggle("color_column") end)
map("", "<Leader>dg", function() toggle("git_signs") end)
map("", "<Leader>db", function() toggle("buffer_sign_column") end)
map("", "<Leader>dd", function() toggle("diagnostics") end)
map("", "<Leader>ds", function() toggle("strict") end)

-- These can be used to set "favorite" HUD settings
local function show_hide_batch(show_names, hide_names)
    -- First sort into 4 categories
    local show_names_multi = tables.filter_array(
        show_names,
        function(display_name)
            return hud[display_name].repeat_buffers == true
        end
    )
    local show_names_singular = tables.filter_array(
        show_names,
        function(display_name)
            return hud[display_name].repeat_buffers == false
        end
    )
    local hide_names_multi = tables.filter_array(
        hide_names,
        function(display_name)
            return hud[display_name].repeat_buffers == true
        end
    )
    local hide_names_singular = tables.filter_array(
        hide_names,
        function(display_name)
            return hud[display_name].repeat_buffers == false
        end
    )

    -- Set all the singular ones
    for _, display_name in ipairs(show_names_singular) do
        hud[display_name].show()
    end
    for _, display_name in ipairs(hide_names_singular) do
        hud[display_name].hide()
    end

    -- Set all the multi ones in single loop
    buf_do(function()
        for _, display_name in ipairs(show_names_multi) do
            hud[display_name].show()
        end
        for _, display_name in ipairs(hide_names_multi) do
            hud[display_name].hide()
        end
    end)
end

-- Convenience Functions that wrap show_hide_batch
local function onlyShow(show_names)
    local show_names_set = tables.array_to_set(show_names)
    local hide_names = {}
    for display_name, _ in pairs(hud) do
        if not show_names_set[display_name] then
            table.insert(hide_names, display_name)
        end
    end

    show_hide_batch(show_names, hide_names)
end
local function onlyHide(hide_names)
    local hide_names_set = tables.array_to_set(hide_names)
    local show_names = {}
    for display_name, _ in pairs(hud) do
        if not hide_names_set[display_name] then
            table.insert(show_names, display_name)
        end
    end

    show_hide_batch(show_names, hide_names)
end

-- Shows all displays
map("", "<Leader>da", function()
	print("Heads Up Display - Show All")
	onlyHide({})
end)

-- Show no displays
map("", "<Leader>dq", function()
	print("Heads Up Display - Hide All")
	onlyShow({})
end)

-- My own verion of "zen mode".
-- For making changes to larger codebase that can be overwhelming
map("", "<Leader>dz", function()
	print("Heads Up Display - Zen Mode")
	onlyShow({ "diagnostics", "git_signs", "footer" })
end)

-- Publication Mode: Strict Diagnostics and the Color Column
map("", "<Leader>dp", function()
	onlyHide({ "relative_line_numbers", "buffer_sign_column" })
end)

function M.default_display()
	print("Heads Up Display - Default Hud")
	onlyHide({ "relative_line_numbers", "strict", "color_column", "buffer_sign_column" })
end

map("", "<Leader>do", M.default_display)

return M
