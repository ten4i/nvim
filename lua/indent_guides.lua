vim.api.nvim_set_hl(0, "IblScope", { fg = "#5f87d7", bold = true })

require("ibl").setup({
  enabled = false,
  indent = { char = "│" },
  scope = {
    enabled = true,
    show_start = false,
    show_end = false,
    highlight = { "IblScope" },
  },
  exclude = {
    filetypes = { "help", "startify", "dashboard", "packer", "neogitstatus", "terminal" },
    buftypes = { "terminal", "nofile" },
  },
})

-- yaml: highlight the guide of the cursor line's indent level, spanning the contiguous
-- block of lines indented at least as deep (plain indentation, no treesitter needed).
-- A whitespace-only line uses its own indent; an empty line uses the nearest non-blank line above.
local ibl_scope = require("ibl.scope")
local orig_scope_get = ibl_scope.get

local function indent_of(line)
  return #line:match("^%s*")
end

local function is_blank(line)
  return line:match("^%s*$") ~= nil
end

ibl_scope.get = function(bufnr, config)
  if not vim.bo[bufnr].filetype:find("yaml", 1, true) then
    return orig_scope_get(bufnr, config)
  end

  local win = vim.api.nvim_get_current_buf() == bufnr and 0 or vim.fn.bufwinid(bufnr)
  if win == -1 then
    return nil
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local cur = vim.api.nvim_win_get_cursor(win)[1]

  local row = cur
  local level
  if is_blank(lines[cur]) and #lines[cur] > 0 then
    -- whitespace-only line (e.g. fresh autoindent): its own indent is the level
    level = #lines[cur]
  else
    while cur > 1 and is_blank(lines[cur]) do
      cur = cur - 1
    end
    level = indent_of(lines[cur])
  end
  if level == 0 or (is_blank(lines[cur]) and cur ~= row) then
    return nil
  end

  local first, last = cur, cur
  for i = cur - 1, 1, -1 do
    if not is_blank(lines[i]) then
      if indent_of(lines[i]) < level then break end
      first = i
    end
  end
  for i = cur + 1, #lines do
    if not is_blank(lines[i]) then
      if indent_of(lines[i]) < level then break end
      last = i
    end
  end
  -- always include the cursor row so its own guide is highlighted too
  first, last = math.min(first, row), math.max(last, row)

  local s_row, e_row = first - 1, last - 1
  local id = ("%d:%d:%d"):format(s_row, e_row, level)
  return {
    start = function() return s_row end,
    end_ = function() return e_row end,
    range = function() return s_row, level, e_row, #lines[last] end,
    id = function() return id end,
    type = function() return "indent_block" end,
  }
end

-- yaml syntax highlighting via treesitter (:TSInstall yaml)
local ok, ts = pcall(require, "nvim-treesitter.configs")
if ok then
  ts.setup({
    ensure_installed = { "yaml" },
    highlight = { enable = true },
  })
end

-- IBL is off globally; turn it on for yaml buffers only
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "yaml", "yaml.docker-compose" },
  callback = function(args)
    require("ibl").setup_buffer(args.buf, { enabled = true })
  end,
})
