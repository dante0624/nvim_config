local array_to_set = require("utils.tables").array_to_set

-- Helper Function
-- Returns only the body of the table, without the opening and closing {}
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

--[[ Turns a lua table (may be nested) to a big strigified version.
This strigified version has tabs for indenting.

Returns that strigified version as a new table,
where each entry is a single line of the big strigified version.]]
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
	-- We separate lines by having seperate entries in this table
	for k, v in ipairs(return_tbl) do
		return_tbl[k] = v:gsub("\n", "")
	end

	return return_tbl
end

-- Define how we fold a buffer
vim.cmd([[
	function! LspInfoFold()
		let thisline = getline(v:lnum)
		if thisline =~ "{$"
			return ">" .. (count(thisline, "\t") + 1)
		endif
		if thisline =~ "}$"
			return "<" .. (count(thisline, "\t") + 1)
		endif
		return count(thisline, "\t")
	endfunction
]])

--[[ Defines how we highlight a buffer
Return all string parsing information for a single line
Returns a numberic table, where each value has the structure:
	{"Highlight group", "starting column index", "ending column index"}
The indicies are based on 0 indexing, and the end is not included ]]
local function parse_line(line)
	-- Edge case of just the first line
	if line == "{" then
		return { { "@constructor", 0, 1 } }
	end

	-- Edge case of closing bracket
	local close_bracket_index = string.find(line, "}")
	if close_bracket_index ~= nil then
		return {
			{ "@constructor", close_bracket_index - 1, close_bracket_index },
		}
	end

	-- All other lines should have '=' in them and be indented at least once
	local equal_index = string.find(line, "=")
	if equal_index == nil then
		return {}
	end

	local line_groups = {
		{ "@operator", equal_index - 1, equal_index },
	}

	-- Get the text before the '='
	local _, last_tab_index = string.find(line, "\t*")
	table.insert(line_groups, { "@property", last_tab_index, equal_index - 2 })

	local line_len = #line
	-- Case 1, the value after the '=' is a table
	if line:sub(line_len, line_len) == "{" then
		table.insert(line_groups, { "@constructor", line_len - 1, line_len })

	-- Case 2, the value after the '=' is a fixed value
	else
		table.insert(line_groups, { "Constant", equal_index + 1, line_len })
	end

	return line_groups
end

-- Gets all parsing information for the buffer
-- See parse_line for how each parser is formatted
local function get_parsing(buffer_number)
	local all_lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
	local parsed_groups = {}

	for line_num, line in ipairs(all_lines) do
		local line_groups = parse_line(line)
		for _, line_group in ipairs(line_groups) do
			-- Add line number to line_group, and convert to 0-index
			table.insert(line_group, line_num - 1)

			-- Add to the big table of all groups
			table.insert(parsed_groups, line_group)
		end
	end

	return parsed_groups
end

local function highlight_buffer(buffer_number)
	for _, parsing in ipairs(get_parsing(buffer_number)) do
		vim.api.nvim_buf_add_highlight(
			buffer_number,
			-1,
			parsing[1],
			parsing[4],
			parsing[2],
			parsing[3]
		)
	end
end

-- If the name is already in use, then its existing buffer number
-- Otherwise, create a new buffer and return the new buffer number
local function create_buffer(name)
	local existing_buffer_number = vim.fn.bufnr(name)

	if existing_buffer_number == -1 then
		local new_buffer_number = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_name(new_buffer_number, name)
		return new_buffer_number
	end

	return existing_buffer_number
end

local function log(data, buffer_number)
	if data then
		-- Clear the buffer's contents incase it has been used
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

	-- Make the buffer listed when we focus it
	vim.bo[buffer_number].buflisted = true

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
