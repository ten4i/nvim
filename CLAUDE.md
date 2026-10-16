# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim configuration (`~/.config/nvim`). There is no build, lint, or test suite. To check a change, restart nvim or run `:source $MYVIMRC` (mapped to `<leader>sv`; `<leader>ev` opens `init.lua`). Leader is `<Space>`.

## Architecture

- `init.lua` is the single entry point, in this order: options, FileType autocmds, vim-plug plugin list (inline `vim.cmd([[ call plug#begin ... ]])`), hotkeys, then `require(...)` of the modules in `lua/`.
- `lua/*.lua` are small modules, each setting up one feature (`lsp_setup`, `autocomplete`, `conform_setup`, `dbui`, `arduino`, `esp`, `ipython_runner`, `telescope_layouts`, `key_hints`, theme and statusline pieces). Core modules are loaded with `require`. Cosmetic ones are loaded with `pcall(require, ...)` so a failure does not break startup.
- `after/ftplugin/{sql,mysql}.vim` and `after/plugin/ts_predicates_fix.lua` hold per-filetype and treesitter overrides. `macros.vim` is sourced from `init.lua`.
- `plugged/` is the vim-plug install directory and is gitignored. Add plugins in the `Plug` list in `init.lua`, then run `:PlugInstall`.

### Two completion/diagnostic stacks (important)

Completion and diagnostics are split between two systems, per filetype:

- **coc.nvim** (`coc-settings.json`) handles Python, C/C++/Arduino, markdown (dictionary source from `vault_dict`), and others. It is disabled per buffer with `vim.b.coc_enabled = 0` for filetypes listed in the "Disable coc" autocmd (currently `lua`). It is explicitly enabled for `c`, `cpp`, `arduino`, `ino`. Its Tab/Shift-Tab/CR mappings use `coc#pum#*`. Node is pinned via `vim.g.coc_node_path` to an nvm path, so update it when the node version changes.
- **Native LSP + nvim-cmp** (`lua/lsp_setup.lua`, `lua/autocomplete.lua`) is used for Lua (`lua_ls`). LSP-only keymaps (such as `]d`/`[d`) are set in a `LspAttach` autocmd and do NOT fire in coc buffers.

When adding a diagnostic or completion feature, decide which stack the target filetype uses. For example, `<leader>e` is `<Plug>(coc-diagnostic-info)` globally, but it is overridden buffer-locally in SQL buffers to run the line via vim-dadbod.

### Keymap notes

- `langmap` maps the Russian ЙЦУКЕН layout to QWERTY for Normal-mode commands.
- `timeoutlen` is 350. Several `<leader>e*` keys (ESP: `eb ef eu em ec et`) share a prefix with `<leader>e`, so `<leader>e` waits for the timeout.
- `<leader>?` opens a cheatsheet of built-in keys and `<leader>/` searches custom keymaps (`lua/key_hints.lua`, `lua/telescope_layouts.lua`). When adding a mapping, give it a `desc` so it shows up there.
- **Always check the cheatsheet when adding, changing, or removing a key.** The hand-written `cheatsheet` table in `lua/telescope_layouts.lua` lists custom mappings too, as `{ "<Space>x", "english text / русский текст" }` (grouped by prefix like `arduino:`, `esp32:`, `db:`). Add or update the matching entry in the same change, with an English and a Russian description, and mark filetype-specific keys like `(sql)`.
- The code has hardcoded local paths and machine-specific values (DB host in `db_connect`, ESP/Arduino toolchains in `coc-settings.json`).
