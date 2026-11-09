-- review marks: files flagged reviewed per repo + branch, kept in stdpath("data")/reviewed/.
-- A mark stores the file's git blob hash, so it lapses once the file changes (GitHub's "Viewed").
local M = {}

local dir = vim.fn.stdpath("data") .. "/reviewed"
local stores = {} -- store file -> { [relpath] = blob }
local hashes = {} -- abs path -> { stamp, blob }, skips re-hashing unchanged files

local function git(root, args)
  local r = vim.system(vim.list_extend({ "git", "-C", root }, args)):wait()
  return r.code == 0 and vim.trim(r.stdout) or nil
end

local function blob(path)
  local st = vim.uv.fs_stat(path)
  if not st then
    return "deleted"
  end
  local stamp = st.mtime.sec .. "." .. st.mtime.nsec .. ":" .. st.size
  local c = hashes[path]
  if not (c and c.stamp == stamp) then
    c = { stamp = stamp, blob = git(vim.fs.dirname(path), { "hash-object", path }) }
    hashes[path] = c
  end
  return c.blob
end

-- a tree render asks for every file; cache roots for good and branches for 2s
local roots, branches = {}, {}

-- root, relpath and store file for an absolute path, or nil outside a repo
local function locate(path)
  local d = vim.fs.dirname(path)
  if roots[d] == nil then
    roots[d] = git(d, { "rev-parse", "--show-toplevel" }) or false
  end
  local root = roots[d]
  if not root then
    return
  end
  local b = branches[root]
  if not (b and vim.uv.now() - b.at < 2000) then
    local name = git(root, { "branch", "--show-current" })
    if not name or name == "" then
      name = git(root, { "rev-parse", "--short", "HEAD" }) or "detached"
    end
    b = { name = name, at = vim.uv.now() }
    branches[root] = b
  end
  local branch = b.name
  local file = dir .. "/" .. (root .. "@" .. branch):gsub("[/\\:]", "%%") .. ".json"
  return root, path:sub(#root + 2), file
end

local function load(file)
  if not stores[file] then
    local f = io.open(file)
    stores[file] = f and vim.json.decode(f:read("*a")) or {}
    if f then
      f:close()
    end
  end
  return stores[file]
end

local function save(file)
  vim.fn.mkdir(dir, "p")
  local f = assert(io.open(file, "w"))
  f:write(vim.json.encode(stores[file]))
  f:close()
end

function M.is_reviewed(path)
  local root, rel, file = locate(path)
  if not root then
    return false
  end
  local mark = load(file)[rel]
  return mark ~= nil and mark == blob(path)
end

function M.toggle(path)
  local root, rel, file = locate(path)
  if not root then
    return vim.notify("not in a git repo", vim.log.levels.WARN)
  end
  local store = load(file)
  store[rel] = not M.is_reviewed(path) and blob(path) or nil
  save(file)
  -- redraw, not refresh: a refresh re-reads git and drops the tree cursor to the root
  if package.loaded["neo-tree"] then
    local state = require("neo-tree.sources.manager").get_state("git_status")
    if state.tree then
      require("neo-tree.ui.renderer").redraw(state)
    end
  end
end

return M
