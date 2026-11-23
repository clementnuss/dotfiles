-- Snacks.gitbrowse for Go files outside any git checkout: the stdlib ($GOROOT) and the module cache
local M = {}

local env
local function go_env()
  if env == nil then
    local ok, r = pcall(function()
      return vim.system({ "go", "env", "-json", "GOROOT", "GOMODCACHE" }):wait()
    end)
    env = ok and r.code == 0 and vim.json.decode(r.stdout) or false
  end
  return env or {}
end

local function read(path)
  local f = io.open(path)
  if not f then
    return
  end
  local s = f:read("*a")
  f:close()
  return s
end

local function rel(file, dir)
  dir = dir and dir ~= "" and vim.uv.fs_realpath(dir)
  return dir and vim.startswith(file, dir .. "/") and file:sub(#dir + 2) or nil
end

-- module cache paths encode uppercase as !lower
local function unescape(s)
  return (s:gsub("!(%l)", string.upper))
end

local function permalink(repo, commit, file, l1, l2)
  return Snacks.gitbrowse.get_url(repo, { commit = commit, file = file, line_start = l1, line_end = l2 }, { what = "permalink" })
end

local function stdlib_url(path, l1, l2)
  local ver = (read(go_env().GOROOT .. "/VERSION") or ""):match("^(go[%w.]+)")
  return permalink("https://github.com/golang/go", ver or "master", path, l1, l2)
end

local function module_url(path, l1, l2)
  local mod, ver, file = path:match("^(.-)@([^/]+)/(.+)$")
  if not mod then
    return
  end
  -- .info carries the exact origin (repo, commit, subdir) for anything fetched by a recent go
  local info = read(("%s/cache/download/%s/@v/%s.info"):format(go_env().GOMODCACHE, mod, ver))
  local origin = info and vim.json.decode(info).Origin
  if origin and origin.Hash and origin.URL then
    local repo = origin.URL:gsub("^https://go%.googlesource%.com/", "https://github.com/golang/"):gsub("%.git$", "")
    return permalink(repo, origin.Hash, (origin.Subdir and origin.Subdir .. "/" or "") .. file, l1, l2)
  end
  mod, ver = unescape(mod), unescape(ver)
  local repo, sub = mod:match("^(github%.com/[^/]+/[^/]+)/?(.*)$")
  if not repo then
    return ("https://pkg.go.dev/%s@%s"):format(mod, ver)
  end
  -- guesswork without .info: a /vN suffix is usually not a directory; nested modules tag as dir/vX.Y.Z
  local dir = sub:gsub("/?v%d+$", "")
  local prefix = dir ~= "" and dir .. "/" or ""
  local ref = ver:match("%d%d%d%d%d%d%d%d%d%d%d%d%d%d%-(%x+)$") or prefix .. ver:gsub("%+incompatible$", "")
  return permalink("https://" .. repo, ref, prefix .. file, l1, l2)
end

local function go_url(l1, l2)
  local file = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0))
  if not file then
    return
  end
  local e = go_env()
  local p = rel(file, e.GOMODCACHE)
  if p then
    return module_url(p, l1, l2)
  end
  p = rel(file, e.GOROOT)
  return p and stdlib_url(p, l1, l2)
end

function M.browse(copy)
  local l1, l2 = vim.fn.line("v"), vim.fn.line(".")
  local url = go_url(math.min(l1, l2), math.max(l1, l2))
  local open = copy and function(u)
    vim.fn.setreg("+", u)
  end or nil
  if not url then
    return Snacks.gitbrowse({ open = open, notify = not copy })
  end
  if copy then
    open(url)
  else
    Snacks.notify(url, { title = "Git Browse" })
    vim.ui.open(url)
  end
end

return M
