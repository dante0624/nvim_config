-- %:p expands out to be the complete path to the current buffer
local full_fname = vim.fn.expand('%:p')

vim.b.run_command = 'node "'..full_fname..'"'-- Wrap out file name in double quotes

