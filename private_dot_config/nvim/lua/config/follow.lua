-- :Follow toggles tail -f on the current buffer: read-only, reloaded every second,
-- pinned to the end while the cursor sits on the last line (move up to pause, G to resume).
local M = {}
local timers = {}

local function stop(buf)
  local t = timers[buf]
  if t then
    t:stop()
    t:close()
    timers[buf] = nil
  end
end

local function tick(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return stop(buf)
  end
  local last = vim.api.nvim_buf_line_count(buf)
  local pinned = {}
  for _, w in ipairs(vim.fn.win_findbuf(buf)) do
    pinned[w] = vim.api.nvim_win_get_cursor(w)[1] >= last
  end
  vim.cmd.checktime(buf)
  for w, at_end in pairs(pinned) do
    if at_end and vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_win_set_cursor(w, { vim.api.nvim_buf_line_count(buf), 0 })
    end
  end
end

local function start(buf)
  vim.bo[buf].readonly = true
  vim.bo[buf].modifiable = false
  vim.bo[buf].autoread = true
  vim.bo[buf].swapfile = false
  local t = vim.uv.new_timer()
  timers[buf] = t
  t:start(0, 1000, vim.schedule_wrap(function()
    tick(buf)
  end))
  vim.api.nvim_create_autocmd("BufWipeout", { buffer = buf, once = true, callback = function()
    stop(buf)
  end })
  vim.cmd("normal! G")
end

function M.setup()
  vim.api.nvim_create_user_command("Follow", function()
    local buf = vim.api.nvim_get_current_buf()
    if timers[buf] then
      stop(buf)
      vim.notify("Follow off")
    else
      start(buf)
      vim.notify("Follow on")
    end
  end, { desc = "Toggle tail -f on the current buffer" })
end

return M
