local filetype_group = vim.api.nvim_create_augroup(
	"filetypes",
	{ clear = true }
)

local function set_file_type(file_type)
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].filetype = file_type
end

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
	pattern = "jdt://*",
	group = filetype_group,
	callback = function()
		set_file_type("java")
	end,
})

vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
	pattern = "*.class",
	group = filetype_group,
	callback = function(event_args)
		-- Usually, jdt://* URIs will also end with .class
		-- But I'm not sure that its guaranteed
		-- Don't want to trigger the same auto-command two times
		if (not vim.startswith(event_args.file, "jdt://")) then
			set_file_type("java")
		end
	end,
})
