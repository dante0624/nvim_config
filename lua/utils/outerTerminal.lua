local M = {}

M.is_ssh = vim.env.SSH_CLIENT ~= nil
M.is_tmux = vim.env.TMUX ~= nil

return M

