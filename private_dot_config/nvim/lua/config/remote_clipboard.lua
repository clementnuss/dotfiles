-- In tmux/SSH: copy goes to both Wayland and OSC 52 (reaches remote clients);
-- paste prefers Wayland, falling back to an OSC 52 query.
local M = {}

function M.setup()
  local in_tmux = vim.env.TMUX ~= nil
  local in_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil

  if not (in_tmux or in_ssh) then
    return
  end

  local osc52 = require("vim.ui.clipboard.osc52")
  local has_wayland = vim.env.WAYLAND_DISPLAY ~= nil
    and vim.fn.executable("wl-copy") == 1
    and vim.fn.executable("wl-paste") == 1

  local function copy(register)
    local emit = osc52.copy(register)

    return function(lines)
      if has_wayland then
        local cmd = { "wl-copy", "--sensitive", "--type", "text/plain" }
        if register == "*" then
          cmd[#cmd + 1] = "--primary"
        end
        vim.fn.system(cmd, lines)
      end

      emit(lines)
    end
  end

  local function paste(register)
    if not has_wayland then
      return osc52.paste(register)
    end

    return function()
      local cmd = { "wl-paste", "--no-newline" }
      if register == "*" then
        cmd[#cmd + 1] = "--primary"
      end

      local lines = vim.fn.systemlist(cmd, "", 1)
      return vim.v.shell_error == 0 and lines or {}
    end
  end

  vim.g.clipboard = {
    name = "RemoteClipboard",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
    cache_enabled = 0,
  }
end

return M
