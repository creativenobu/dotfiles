local M = {}

M.config = function()
  require 'projectcmd'.setup {
    -- key = os.getenv('NVIMRC_PROJECTCMD_KEY'),
    key = 'SECRET_KEY',
    type = 'lua',
    autoload = true
  }
end

return M
