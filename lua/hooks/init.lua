local M = {}
M.items = {}

local data_dir = vim.fn.stdpath("data") .. "/hooks"
vim.fn.mkdir(data_dir, "p")

local ns_id = vim.api.nvim_create_namespace("Hooks")

local function _get_path()
  local context

  local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code ~= 0 then
    context = "global"
  else
    context = result.stdout:gsub("\n", ""):gsub("/", "_")
  end

  return data_dir .. "/" .. context
end

---Save current state
local function _save_state()
  local path = _get_path()

  vim.fn.writefile({ vim.json.encode(M.items) }, path)
end

local function _load_state()
  local path = _get_path()

  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({ "[]" }, path)
  end

  local content = table.concat(vim.fn.readfile(path))
  M.items = vim.json.decode(content) or {}
end

function M.buffer(index)
  _load_state()
  if M.items[index] then
    vim.cmd.edit(M.items[index])
  end
end

function M.append()
  _load_state()
  local file = vim.fn.expand("%:p")

  if file == "" or vim.bo.buftype ~= "" then
    return
  end

  for i, existing in ipairs(M.items) do
    if existing == file then
      local name = vim.fn.fnamemodify(file, ":t")
      vim.notify( "Hooks: Buffer [" .. name .. "] already present at index [" .. i .. "]", vim.log.levels.WARN )
      return
    end
  end

  table.insert(M.items, file)
  _save_state()

  local index = #M.items
  local name = vim.fn.fnamemodify(file, ":t")

  vim.notify( "Hooks: Buffer [" .. name .. "] added at index [" .. index .. "]", vim.log.levels.INFO )
end

function M.jump(key)
  return M.buffer(tonumber(key))
end

function M.list()
  _load_state()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "HooksList")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, M.items)
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "delete", { buf = buf })

  local width = math.floor(vim.o.columns * 0.5)
  local height = math.floor(vim.o.lines * 0.5)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height)/2),
    col = math.floor((vim.o.columns - width)/2),
    border = "rounded",
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(0, true)
  end, { buffer = buf, silent = true })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local new = {}

      for _, line in ipairs(lines) do
        local trimmed = vim.fn.trim(line)
        if trimmed ~= "" and vim.fn.filereadable(vim.fn.expand(trimmed)) == 1 then
          table.insert(new, trimmed)
        end
      end

      M.items = new
      _save_state()

      vim.api.nvim_set_option_value("modified", false, { buf = buf })
      vim.api.nvim_win_close(0, true)
    end,
  })
end

return M
