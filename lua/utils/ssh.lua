local M = {}

M.is_ssh = vim.env.SSH_CLIENT ~= nil
M.has_display = vim.env.DISPLAY ~= nil
M.is_ssh_x11 = M.is_ssh and M.has_display

return M

