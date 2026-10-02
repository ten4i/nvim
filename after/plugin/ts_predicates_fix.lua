-- nvim-treesitter `master` is archived and its query directives expect a single
-- node per capture. Neovim 0.12 always passes a list of nodes, which crashes
-- markdown code-block injections ("attempt to call method 'range'").
-- Re-register the affected predicates/directives so they handle node lists.
if vim.fn.has("nvim-0.12") == 0 then
  return
end

local ok = pcall(require, "nvim-treesitter.query_predicates")
if not ok then
  return
end

local query = vim.treesitter.query
local opts = { force = true, all = true }

-- last node of a capture (match[id] is TSNode[] with all = true)
local function node_of(match, id)
  local nodes = match[id]
  if type(nodes) == "table" then
    return nodes[#nodes]
  end
  return nodes
end

local lang_aliases = {
  ex = "elixir",
  pl = "perl",
  sh = "bash",
  uxn = "uxntal",
  ts = "typescript",
}

local html_script_types = {
  ["importmap"] = "json",
  ["module"] = "javascript",
  ["application/ecmascript"] = "javascript",
  ["text/ecmascript"] = "javascript",
}

query.add_predicate("nth?", function(match, _, _, pred)
  local node = node_of(match, pred[2])
  local n = tonumber(pred[3])
  if node and node:parent() and node:parent():named_child_count() > n then
    return node:parent():named_child(n) == node
  end
  return false
end, opts)

query.add_predicate("is?", function(match, _, bufnr, pred)
  local node = node_of(match, pred[2])
  if not node then
    return true
  end
  local _, _, kind = require("nvim-treesitter.locals").find_definition(node, bufnr)
  return vim.tbl_contains({ unpack(pred, 3) }, kind)
end, opts)

query.add_predicate("kind-eq?", function(match, _, _, pred)
  local node = node_of(match, pred[2])
  if not node then
    return true
  end
  return vim.tbl_contains({ unpack(pred, 3) }, node:type())
end, opts)

query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
  local node = node_of(match, pred[2])
  if not node then
    return
  end
  local value = vim.treesitter.get_node_text(node, bufnr)
  local parts = vim.split(value, "/", {})
  metadata["injection.language"] = html_script_types[value] or parts[#parts]
end, opts)

query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
  local node = node_of(match, pred[2])
  if not node then
    return
  end
  local alias = vim.treesitter.get_node_text(node, bufnr):lower()
  metadata["injection.language"] = vim.filetype.match({ filename = "a." .. alias })
    or lang_aliases[alias]
    or alias
end, opts)

query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
  local id = pred[2]
  local node = node_of(match, id)
  if not node then
    return
  end
  local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
  metadata[id] = metadata[id] or {}
  metadata[id].text = string.lower(text)
end, opts)
