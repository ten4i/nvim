local M = {}

local builtin = require("telescope.builtin")
local themes = require("telescope.themes")
local telescope = require("telescope")

-- =========================================================
-- SMART LAYOUT
-- =========================================================

local function smart_layout(force_preview)
  local columns = vim.o.columns

  -- 🔹 Очень узкий терминал
  if columns < 90 then
    -- если force_preview = true → не используем ivy
    if not force_preview then
      return themes.get_ivy({
        previewer = false,
      })
    end

    -- fallback если нужен preview
    return {
      previewer = true,
      layout_strategy = "vertical",
      layout_config = {
        vertical = {
          preview_height = 0.5,
          prompt_position = "bottom",
        },
        width = 0.95,
        height = 0.95,
      },
    }
  end

  -- 🔹 Средний размер
  if columns < 140 then
    return {
      previewer = true,
      layout_strategy = "vertical",
      layout_config = {
        vertical = {
          preview_height = 0.5,
          prompt_position = "bottom",
        },
        width = 0.95,
        height = 0.95,
      },
    }
  end

  -- 🔹 Широкий экран
  return {
    previewer = true,
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        preview_width = 0.55,
        prompt_position = "bottom",
      },
      width = 0.9,
      height = 0.9,
    },
  }
end

-- bottom-pane (ivy) pickers: cap the list at ~20 result rows
local function cap_height(opts)
  if opts.layout_strategy == "bottom_pane" then
    opts.layout_config = vim.tbl_extend("force", opts.layout_config or {}, { height = 23 })
  end
  return opts
end

-- =========================================================
-- BUILTIN PICKERS
-- =========================================================

function M.find_files()
  builtin.find_files(smart_layout())
end

function M.buffers()
  builtin.buffers(smart_layout())
end

function M.live_grep()
  builtin.live_grep(smart_layout())
end

function M.keymaps()
  builtin.keymaps(cap_height(vim.tbl_extend("force", smart_layout(), { show_plug = false, previewer = false })))
end

-- searchable list of keys: built-in Neovim keys (not mappings, so :Telescope keymaps can't see them)
-- plus a short description for every custom mapping, in English and Russian
local cheatsheet = {
  { "za", "fold: toggle fold under cursor / переключить складку" },
  { "zo", "fold: open fold under cursor / открыть складку" },
  { "zc", "fold: close fold under cursor / закрыть складку" },
  { "zO", "fold: open fold and all nested / открыть вложенные складки" },
  { "zC", "fold: close fold and all parents / закрыть вложенные складки" },
  { "zR", "fold: open all folds in file / открыть все складки" },
  { "zM", "fold: close all folds in file / закрыть все складки" },
  { "zz", "fold: toggle all open/closed (mine) / открыть или закрыть все" },
  { "zr", "fold: open one level deeper / открыть на уровень глубже" },
  { "zm", "fold: close one level deeper / закрыть на уровень глубже" },
  { "zj", "fold: move to next fold / к следующей складке" },
  { "zk", "fold: move to end of previous fold / к предыдущей складке" },
  { "[z", "fold: move to start of current fold / к началу складки" },
  { "]z", "fold: move to end of current fold / к концу складки" },
  { "<Space>am", "arduino: serial monitor / монитор порта" },
  { "<Space>ar", "arduino: restart serial monitor / перезапуск монитора порта" },
  { "<Space>as", "arduino: sync / синхронизация" },
  { "<Space>au", "arduino: upload sketch / загрузить скетч" },
  { "<Space>ab", "arduino: choose board / выбрать плату" },
  { "<Space>eb", "esp32: build / собрать" },
  { "<Space>ef", "esp32: flash / прошить" },
  { "<Space>eu", "esp32: upload / загрузить" },
  { "<Space>em", "esp32: monitor / монитор" },
  { "<Space>ec", "esp32: menuconfig / настройки проекта" },
  { "<Space>et", "esp32: set target chip / выбрать чип" },
  { "<Space>r", "python: run current file in shell / запустить файл" },
  { "<Space>pp", "python: open ipython terminal (Termpy) / открыть терминал ipython" },
  { "<Space>pp (visual)", "python: send selection to ipython / отправить выделение в ipython" },
  { "<Space>lp", "python: run current line in ipython / выполнить строку" },
  { "<Space>fp", "python: run whole file in ipython / выполнить файл" },
  { "<F5>", "debug: toggle breakpoint / точка останова" },
  { "<F6>", "debug: continue / продолжить" },
  { "<F2>", "debug: step over / шаг через" },
  { "<F3>", "debug: step into / шаг внутрь" },
  { "<F4>", "debug: step out / шаг наружу" },
  { "<F7>", "debug: terminate / остановить отладку" },
  { "<S-Left> / <S-Right>", "buffer: previous / next tab / вкладка назад, вперёд" },
  { "<Space>c", "buffer: close buffer / закрыть буфер" },
  { "<S-Up> / <S-Down>", "move: 8 lines up / down / на 8 строк вверх, вниз" },
  { "<Space>w", "window: window commands prefix (<C-w>) / команды окон" },
  { "ff", "telescope: find files / найти файл" },
  { "fb", "telescope: file browser / файловый менеджер" },
  { "fr", "telescope: buffers / список буферов" },
  { "fh", "telescope: help tags / справка" },
  { "f.", "telescope: file browser in current dir / менеджер в папке файла" },
  { "fg", "telescope: live grep / поиск по тексту" },
  { "<C-g>", "telescope: live grep (smart layout) / поиск по тексту" },
  { "<Space>ll", "telescope: open a nvim lua config file / файлы конфига lua" },
  { "<Space>?", "this cheatsheet / эта шпаргалка" },
  { "<Space>/", "search my keymaps / поиск по привязкам" },
  { "<Space>ev", "config: edit init.lua / редактировать конфиг" },
  { "<Space>sv", "config: reload init.lua / перезагрузить конфиг" },
  { "<Space>vd", "markdown: rebuild vault dictionary / пересобрать словарь" },
  { "<Space>bf", "format: format buffer (conform) / форматировать файл" },
  { "<Space>rp", "repeat: insert repeated text template / повторить текст" },
  { "<Space>h", "search: clear highlight / убрать подсветку поиска" },
  { "<Space>y / <Space>p", "clipboard: yank / paste system + / копировать, вставить (буфер +)" },
  { "<Space>Y / <Space>P", "clipboard: yank / paste selection * / копировать, вставить (буфер *)" },
  { "<C-c> / <C-x> (visual)", "clipboard: copy / cut to system / копировать, вырезать" },
  { "<C-z> (insert)", "undo last change / отменить" },
  { "<C-h> (insert)", "delete previous word / удалить слово" },
  { "< / > (visual)", "indent and keep selection / отступ без потери выделения" },
  { "Q", "record macro (q is disabled) / запись макроса" },
  { "<C-y>", "markdown: wrap word/line/selection in `code` / обернуть в код" },
  { "<C-S-y> (visual)", "markdown: wrap selection in code fence / блок кода" },
  { "<Space>t", "terminal: open terminal / открыть терминал" },
  { "<Space>cl", "terminal: run claude / запустить claude" },
  { "<Esc> (terminal)", "terminal: back to normal mode / выйти в normal" },
  { "<C-j> / <C-k> (insert)", "snippet: next / previous placeholder (coc) / сниппет вперёд, назад" },
  { "<Space>e", "diagnostics: show float / показать ошибку (в sql: выполнить строку)" },
  { "]d / [d", "diagnostics: next / previous / следующая, предыдущая" },
  { "<Space>db", "db: toggle DBUI / панель баз данных" },
  { "<Space>dc", "db: connect / подключиться" },
  { "<Space>e (sql)", "db: run line or selection / выполнить строку или выделение" },
  { "<Space>S (sql)", "db: run whole file / выполнить файл" },
}

function M.cheatsheet()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")

  pickers
    .new(cap_height(vim.tbl_extend("force", smart_layout(), { previewer = false })), {
      prompt_title = "Cheatsheet",
      finder = finders.new_table({
        results = cheatsheet,
        entry_maker = function(e)
          local text = ("%-6s %s"):format(e[1], e[2])
          return { value = e, display = text, ordinal = text }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function()
        actions.select_default:replace(actions.close)
        return true
      end,
    })
    :find()
end

-- =========================================================
-- FILE BROWSER (EXTENSION)
-- =========================================================

function M.file_browser()
  telescope.extensions.file_browser.file_browser(
    smart_layout(true) -- принудительно с preview
  )
end

-- Telescope borders for Kansō
vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#545464", bg = "NONE" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#7e9cd8", bg = "NONE" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#545464", bg = "NONE" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#545464", bg = "NONE" })

vim.api.nvim_set_hl(0, "TelescopePromptTitle", { fg = "#1f1f28", bg = "#7e9cd8", bold = true })
vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { fg = "#1f1f28", bg = "#957fb8", bold = true })
vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { fg = "#1f1f28", bg = "#dcd7ba", bold = true })


return M

