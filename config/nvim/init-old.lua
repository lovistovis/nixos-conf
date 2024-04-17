local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local save_session_on_exit_group = augroup('SaveSessionOnExit', {})

autocmd({"VimLeave"}, {
    group = save_session_on_exit_group,
    pattern = "*",
    command = [[mksession!]],
})
