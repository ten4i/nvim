# Neovim config

Личный конфиг Neovim (`~/.config/nvim`). Менеджер плагинов: vim-plug. Leader: `<Space>`.
Подробнее об архитектуре (два стека автодополнения, keymap-ы) см. `CLAUDE.md`.

## 1. Системные зависимости

Проверено на Ubuntu, Neovim 0.12.

1. Базовые пакеты
```
sudo apt install -y \
  git curl unzip ripgrep fd-find tmux \
  python3 python3-pip pipx \
  clangd tealdeer
```

2. Neovim версии 0.11 или новее (используется `vim.diagnostic.jump`). Установите из релизов https://github.com/neovim/neovim/releases или через snap
```
sudo snap install nvim --classic
```

3. Шрифт Nerd Font в терминале (kitty). Нужен для иконок lualine, barbar, devicons. Скачайте с https://www.nerdfonts.com и выберите его в настройках терминала.

4. Node.js через nvm. Нужен для coc.nvim
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install 24
```
Путь к node прописан в `init.lua` (`vim.g.coc_node_path`). После смены версии обновите его.

5. vim-plug
```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

## 2. Установка конфига

1. Клонирование (или копирование папки) в `~/.config/nvim`
```
git clone <repo-url> ~/.config/nvim
```

2. Первый запуск и установка плагинов
```
nvim +PlugInstall +qall
```

3. Парсеры treesitter. В nvim выполните
```
:TSInstall lua python bash markdown markdown_inline yaml helm dockerfile c cpp sql
```

## 3. Расширения coc.nvim

В nvim
```
:CocInstall coc-pyright coc-yaml coc-sh coc-clangd coc-dictionary coc-docker coc-marketplace
```
Настройки лежат в `coc-settings.json`: схема Kubernetes для `*.yml` и `*.yaml`, словарь для markdown, параметры clangd, сервер `helm_ls`.

## 4. Языковые серверы и инструменты

### Lua (нативный LSP, `lua/lsp_setup.lua`)
`lua-language-server` ожидается в `~/.local/share/lua-language-server/bin/`. Скачайте релиз с https://github.com/LuaLS/lua-language-server/releases и распакуйте в `~/.local/share/lua-language-server`.

### Helm
1. Бинарник `helm_ls` (проверка контрольной суммы: файл `.sha256sum` рядом с релизом)
```
curl -L -o ~/.local/bin/helm_ls \
  https://github.com/mrjosh/helm-ls/releases/download/v0.5.4/helm_ls_linux_amd64
chmod +x ~/.local/bin/helm_ls
```
2. Filetype `helm` задаётся в `init.lua` для `templates/*.yaml` внутри чарта (есть `Chart.yaml` выше по дереву) и для `*.tpl`. Проверка: `:set filetype?`.

### Python
1. Форматирование (`conform.nvim`) и отладка
```
pipx install black
pipx install isort
pipx install ipython
pip install --user debugpy
```
2. Пути: `<leader>bf` форматирует (isort, затем black), `<leader>r` запускает файл, `<leader>pp` открывает IPython.

### Docker и Kubernetes
`coc-docker` ставится в разделе 3. Для проверки манифестов нужны `kubectl` и `helm`.

### tldr
1. База страниц, один раз
```
tldr --update
```

## 5. Опциональные части

Эти части привязаны к конкретной машине. Без них конфиг загружается, но соответствующие клавиши не работают.

| Часть | Что нужно |
|---|---|
| Arduino (`<leader>a*`) | `arduino-cli`, ядра `arduino:avr`, `esp8266:esp8266`, порт в `lua/arduino.lua` |
| ESP-IDF (`<leader>e*`) | ESP-IDF в `~/MCU/EspIdfToolchain`, скрипт `~/Scripts/IdfSyncUpload.sh`, порт в `lua/esp.lua` |
| Базы данных (`<leader>db`, `<leader>dc`) | Переменная окружения `MYSQL_PASS`, хост и пользователь в `lua/dbui.lua` и `init.lua`, клиент `mysql` |
| Словарь markdown | Каталог `~/Documents/Sync_vault` и `ripgrep`; словарь строится в `~/.cache/nvim/vault-dict.txt` (`<leader>vd`) |
| Навигация tmux | `tmux` и плагин на стороне tmux для `vim-tmux-navigator` |
| Отладка Python (`<F2>`-`<F7>`) | `debugpy` |

Жёстко заданные пути (`/home/ten4i/...`, IP базы данных, порты) нужно заменить на свои.

## 6. Проверка установки

1. Состояние здоровья Neovim
```
:checkhealth
```
2. Запущенные серверы coc
```
:CocList services
```
3. Тип файла и работа сервера
```
:set filetype?
```

## 7. Полезные клавиши

- `<leader>?` шпаргалка встроенных клавиш
- `<leader>/` поиск по своим mappings
- `<leader>ev` и `<leader>sv` открыть и перечитать `init.lua`
- `<leader>e` показать ошибку под курсором
