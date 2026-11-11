local M = {}

local function buf_dir()
  local dir = vim.fn.expand("%:p:h")
  return (dir ~= "" and vim.fn.isdirectory(dir) == 1) and dir or vim.uv.cwd()
end

-- the default branch (main/master) of the remote the current branch tracks, then upstream,
-- then origin: in a fork, origin/master can be years stale. Local main/master is the fallback.
function M.default_branch()
  local dir = buf_dir()
  local function out(args)
    local r = vim.system(vim.list_extend({ "git", "-C", dir }, args)):wait()
    return r.code == 0 and vim.trim(r.stdout) or nil
  end
  local function ok(ref)
    return out({ "rev-parse", "--verify", "--quiet", ref }) ~= nil
  end
  local tracked = (out({ "rev-parse", "--abbrev-ref", "@{u}" }) or ""):match("^([^/]+)/")
  local remotes = {}
  for _, r in ipairs({ tracked, "upstream", "origin" }) do
    if r and not vim.tbl_contains(remotes, r) then
      table.insert(remotes, r)
    end
  end
  for _, r in ipairs(remotes) do
    local head = (out({ "rev-parse", "--abbrev-ref", r .. "/HEAD" }) or ""):match("^" .. r .. "/(.+)")
    for _, name in ipairs(head and { head } or { "main", "master" }) do
      if ok(r .. "/" .. name) then
        return r .. "/" .. name
      end
    end
  end
  for _, name in ipairs({ "main", "master" }) do
    if ok(name) then
      return name
    end
  end
  vim.notify("no main/master branch here", vim.log.levels.WARN)
end

-- where the current branch forked from main/master, i.e. what GitHub diffs a PR against:
-- diffing the branch tip instead shows master's newer commits as deletions
function M.review_base()
  local branch = M.default_branch()
  if not branch then
    return
  end
  local r = vim.system({ "git", "-C", buf_dir(), "merge-base", branch, "HEAD" }):wait()
  if r.code ~= 0 then
    return vim.notify("no merge-base with " .. branch, vim.log.levels.WARN)
  end
  return vim.trim(r.stdout), branch
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
