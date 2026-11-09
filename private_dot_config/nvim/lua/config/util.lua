local M = {}

local function buf_dir()
  local dir = vim.fn.expand("%:p:h")
  return (dir ~= "" and vim.fn.isdirectory(dir) == 1) and dir or vim.uv.cwd()
end

-- the current buffer's repo default branch (main or master): local if it exists, else origin/<name>
function M.default_branch()
  local dir = buf_dir()
  local function ok(ref)
    return vim.system({ "git", "-C", dir, "rev-parse", "--verify", "--quiet", ref }):wait().code == 0
  end
  local head = vim.system({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "origin/HEAD" }):wait()
  local remote = head.code == 0 and vim.trim(head.stdout):match("^origin/(.+)") or nil
  for _, name in ipairs(remote and { remote } or { "main", "master" }) do
    if ok(name) then
      return name
    end
    if ok("origin/" .. name) then
      return "origin/" .. name
    end
  end
  vim.notify("no main/master branch here", vim.log.levels.WARN)
end

-- true while no-neck-pain's side windows are up in this tab
function M.centered()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "no-neck-pain" then
      return true
    end
  end
  return false
end

return M
