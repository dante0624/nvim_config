local array_to_set = require("utils.tables").array_to_set
local create_buffer = require("utils.buffers").create_buffer

--- Returns only the body of the table, without the opening and closing {}.
--- Uses recursion to handle sub tables.
--- @param tbl table the table to stringify
--- @param indent any the current recursive "depth"
--- @param ignored_keys_set table miscellaneous keys, all values are `true`
--- @return string[] stringified_lines each stringified line in order.
local function tbl_lines_body(tbl, indent, ignored_keys_set)
	local stringified_lines = {}

	-- Alphabetize the keys
	local alphabetized_keys = {}
	for k, _ in pairs(tbl) do
		table.insert(alphabetized_keys, k)
	end
	table.sort(alphabetized_keys)

	for _, key in ipairs(alphabetized_keys) do
		local value = tbl[key]
		local key_formatted = string.rep("\t", indent) .. key .. " = "
		if ignored_keys_set[key] ~= nil then
			-- Ignore this key
			-- Would call 'Continue' if lua had support for that

		-- Recursive Case
		elseif type(value) == "table" then
			table.insert(stringified_lines, key_formatted .. "{")

			local sub_tbl = tbl_lines_body(value, indent + 1, ignored_keys_set)

			for _, v in ipairs(sub_tbl) do
				table.insert(stringified_lines, v)
			end

			table.insert(stringified_lines, string.rep("\t", indent) .. "}")

		-- Base Case
		else
			table.insert(stringified_lines, key_formatted .. tostring(value))
		end
	end

	return stringified_lines
end

--- Turns a lua table (may be nested) to a big stringified version.
--- Uses recursion to handle sub tables.
--- @param tbl table the table to stringify
--- @param ignored_keys_array string[] miscellaneous keys to ignore
--- @return string[] stringified_lines each stringified line in order.
local function tbl_to_lines(tbl, ignored_keys_array)
	-- Make an associative table, this way we can instantly index later
	local ignored_keys_set = array_to_set(ignored_keys_array)

	local return_tbl = { "{" }
	local lines = tbl_lines_body(tbl, 1, ignored_keys_set)
	for _, line in ipairs(lines) do
		table.insert(return_tbl, line)
	end
	table.insert(return_tbl, "}")

	-- Remove all newline characters that might exist
	-- We separate lines by having separate entries in this table
	for k, v in ipairs(return_tbl) do
		return_tbl[k] = v:gsub("\n", "")
	end

	return return_tbl
end

-- Define how we fold a buffer
vim.cmd([[
	function! LspInfoFold()
		let this_line = getline(v:lnum)
		if this_line =~ "{$"
			return ">" .. (count(this_line, "\t") + 1)
		endif
		if this_line =~ "}$"
			return "<" .. (count(this_line, "\t") + 1)
		endif
		return count(this_line, "\t")
	endfunction
]])

--- @class HighlightInfo
--- @field higroup string highlight group to use for highlighting
--- @field line_num integer 0-indexed line number
--- @field col_start integer 0-indexed column number (inclusive)
--- @field col_end integer 0-indexed column number (exclusive)

--- Parse a single line into its highlight groups
--- @param line string stringified line of a buffer
--- @param line_num integer 0-indexed line number
--- @return HighlightInfo[] line_groups all highlight info for this line
local function parse_highlights_from_line(line, line_num)
	-- Edge case of just the first line
	if line == "{" then
		return { {
			higroup = "@constructor",
			line_num = line_num,
			col_start = 0,
			col_end = 1,
		} }
	end

	-- Edge case of closing bracket
	local close_bracket_index = string.find(line, "}")
	if close_bracket_index ~= nil then
		return { {
			higroup = "@constructor",
			line_num = line_num,
			col_start = close_bracket_index - 1,
			col_end = close_bracket_index,
		} }
	end

	-- All other lines should have '=' in them and be indented at least once
	local equal_index = string.find(line, "=")
	if equal_index == nil then
		return {}
	end

	local line_groups = { {
		higroup = "@operator",
		line_num = line_num,
		col_start = equal_index - 1,
		col_end = equal_index,
	} }

	-- Get the text before the '='
	local _, last_tab_index = string.find(line, "\t*")
	table.insert(line_groups, {
		higroup = "@property",
		line_num = line_num,
		col_start = last_tab_index,
		col_end = equal_index - 2,
	})

	local line_len = #line
	-- Case 1, the value after the '=' is a table
	if line:sub(line_len, line_len) == "{" then
		table.insert(line_groups, {
			higroup = "@constructor",
			line_num = line_num,
			col_start = line_len - 1,
			col_end = line_len
		})

	-- Case 2, the value after the '=' is a fixed value
	else
		table.insert(line_groups, {
			higroup = "Constant",
			line_num = line_num,
			col_start = equal_index + 1,
			col_end = line_len
		})
	end

	return line_groups
end

--- Parse entire buffer into its highlight groups
--- @param buffer_number integer Buffer id, or 0 for current buffer
--- @return HighlightInfo[] parsed_groups all highlight info for this buffer
local function get_highlight_parsing(buffer_number)
	local all_lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
	local parsed_groups = {}

	for line_num, line in ipairs(all_lines) do
		-- Convert line_num from 1-based indexing to 0-based indexing
		local line_groups = parse_highlights_from_line(line, line_num - 1)

		for _, line_group in ipairs(line_groups) do
			-- Add to the big table of all groups
			table.insert(parsed_groups, line_group)
		end
	end

	return parsed_groups
end

local function highlight_buffer(buffer_number)
	local anonymous_namespace_id = vim.api.nvim_create_namespace("")

	for _, highlight_info in ipairs(get_highlight_parsing(buffer_number)) do
		vim.hl.range(
			buffer_number,
			anonymous_namespace_id,
			highlight_info.higroup,
			{ highlight_info.line_num, highlight_info.col_start },
			{ highlight_info.line_num, highlight_info.col_end }
		)
	end
end

local function log(data, buffer_number)
	if data then
		-- Clear the buffer's contents in case it has been used
		vim.api.nvim_buf_set_lines(buffer_number, 0, -1, true, {})

		-- Write to the buffer
		vim.api.nvim_buf_set_lines(buffer_number, 0, 0, true, data)

		-- Say that it is unmodified, this way it can be easily deleted
		vim.bo[buffer_number].modified = false

		-- Highlight the buffer
		highlight_buffer(buffer_number)
	end
end

local function focus_buffer(buffer_number)
	-- Get the window the buffer is in and set the cursor position to the top
	vim.cmd("buffer " .. buffer_number)
	local buffer_window =
		vim.api.nvim_call_function("bufwinid", { buffer_number })
	vim.api.nvim_win_set_cursor(buffer_window, { 1, 0 })

	-- Set the folding type to be correct
	vim.cmd([[
		setlocal foldmethod=expr
		setlocal foldexpr=LspInfoFold()
	]])
	vim.cmd("normal! zR")
end

--[[ Given a table, send it to an output buffer to be visualized.
Give that buffer a unique name (emphasis on unique!)
and specify a list of keys (as strings) to ignore from the table]]
return function(tbl, name, ignored_keys_array)
	if name == nil then
		name = "((showTable output))"
	end
	if ignored_keys_array == nil then
		ignored_keys_array = {}
	end

	local buffer_number = create_buffer(name)
	log(tbl_to_lines(tbl, ignored_keys_array), buffer_number)
	focus_buffer(buffer_number)
end
