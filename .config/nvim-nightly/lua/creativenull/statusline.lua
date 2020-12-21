local vim = vim
local lsp_status = require 'lsp-status'

local Statusline = {}

-- Returns the vim mode
function Statusline.mode()
    local mode_map = {
        ['n'] = 'NORMAL',
        ['v'] = 'VISUAL',
        ['V'] = 'V-LINE',
        [''] = 'V-BLOCK',
        ['i'] = 'INSERT',
        ['R'] = 'REPLACE',
        ['Rv'] = 'V-REPLACE',
        ['c'] = 'COMMAND',
    }
    local m = vim.api.nvim_get_mode()
    local current_mode = mode_map[m.mode]

    return string.format(' %s ', current_mode)
end

-- Get the current git branch
-- inspired from github.com/galaxyline/provider_vcs.lua
function Statusline.git_branch()
    local fp = io.open(vim.fn.getcwd() .. '/.git/HEAD')
    if fp == nil then return '' end

    local HEAD = fp:read()
    fp:close()

    local branch = HEAD:match('ref: refs/heads/(.+)')
    if branch == '' then return '' end

    return string.format('  %s ', branch)
end

-- Get the current buffer name
function Statusline.filename()
    local left_sep_line = ""
    local bufname = vim.fn.expand('%:t')
    if bufname == '' then return '' end

    return string.format('%s %s ', left_sep_line, bufname)
end

-- nvim-lsp status diagnostics
function Statusline.lsp()
    local diagnostics = lsp_status.diagnostics()
    if diagnostics.errors > 0 or diagnostics.warnings > 0 then
        return string.format('LSP %d 🔴 %d 🟡 ', diagnostics.errors, diagnostics.warnings)
    end

    return 'LSP '
end

function Statusline.set_highlights()
    local statusline_bg = vim.fn.synIDattr(vim.fn.hlID('StatusLine'), 'fg#')
    local statusline_fg = vim.fn.synIDattr(vim.fn.hlID('StatusLine'), 'bg#')

    local aqua = '#689d6a'
    local blue = '#458588'
    local purple = '#b16286'

    -- BlueBg
    vim.cmd(string.format('hi User1 guifg=#1d2021 guibg=%s', blue))
    -- AquaBg
    vim.cmd(string.format('hi User2 guifg=#1d2021 guibg=%s', aqua))
    -- PurpleBg
    vim.cmd(string.format('hi User3 guifg=#1d2021 guibg=%s', purple))

    -- Seperator colors
    -- bluefg -> aquabg
    vim.cmd(string.format('hi User7 guifg=%s guibg=%s', blue, aqua))
    -- bluefg -> statuslinebg
    vim.cmd(string.format('hi User8 guifg=%s guibg=%s', aqua, statusline_bg))
    -- statuslinebg -> purplefg
    vim.cmd(string.format('hi User9 guifg=%s guibg=%s', purple , statusline_bg))
end

-- Render the statusline
function Statusline.render()
    local status = ''

    -- Feeling Hacky? Use this
    -- local left_sep = vim.fn.eval([[printf("\uE0B8")]])
    -- local right_sep = vim.fn.eval([[printf("\uE0BA")]])

    local left_sep = ""
    local right_sep = ""

    Statusline.set_highlights()

    -- left side
    status = status .. '%1*'
    status = status .. Statusline.mode()
    status = status .. '%7*' .. left_sep
    status = status .. '%2*' .. Statusline.git_branch()
    status = status .. Statusline.filename()
    status = status .. '%8*' .. left_sep .. ' '
    status = status .. '%*%-m %-r'

    -- right side
    status = status .. '%='
    status = status .. '%y  %l/%L '
    status = status .. '%9*' .. right_sep
    status = status .. '%3* '
    status = status .. Statusline.lsp() .. '%*'

    return status
end

return Statusline