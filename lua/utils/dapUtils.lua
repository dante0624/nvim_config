local M = {}

function M.terminate_and_cleanup()
	local dap = require("dap")

	local current_session = dap.session()
	if current_session == nil then
		-- Ensures that calling this function is idempotent
		return
	end
	local all_sessions = dap.sessions()

	dap.terminate({ on_done = function()
		assert(
			current_session.closed,
			"Terminate call did not set the current session to closed"
		)
		all_sessions[current_session.id] = nil
		dap.set_session(nil)
	end })
end

--[[
Create a view object and save it under the session table for easy access.
If the view object already exists, it will just open it.

Options for widget_builder_key are currently:
	sidebar - split window
	centered_float - large floating window
	cursor_float - small floating window, right next to the cursor
Options for widget_key are currently:
	scopes - veriables in scope
	sessions - DAP sessions
	frames - The stacktrace
	expression
	threads

wincmd (optional) only applies if using sidebar. Some sensible strings are:
	"30 vsplit" (the default set by dap plugin)
	"15 split"
]]
function M.open_or_create_widget(widget_builder_key, widget_key, wincmd)
	local dap = require("dap")
	local widgets = require('dap.ui.widgets')

	local session = dap.session()
	if session == nil then
		print("Cannot create a widget, there is no session")
		return
	end
	if session.closed then
		print("Not creating a widget because the session is closed")
		return
	end
	if session.widgets == nil then
		session.widgets = {}
	end
	if session.widgets[widget_builder_key] == nil then
		session.widgets[widget_builder_key] = {}
	end

	local view
	if session.widgets[widget_builder_key][widget_key] == nil then
		local builder_func = widgets[widget_builder_key]
		if widget_builder_key == "sidebar" then
			view = builder_func(widgets[widget_key], nil, wincmd)
		else
			view = builder_func(widgets[widget_key])
		end
		session.widgets[widget_builder_key][widget_key] = view
	else
		view = session.widgets[widget_builder_key][widget_key]
	end

	local _, win_id = view.open()
	vim.api.nvim_set_current_win(win_id)
end

return M
