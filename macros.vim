"записываем макром через q
"затем переходим в ~/.config/nvim/macros.vim
"команда для вставки макроса, вместо 'с' наш символ
" :put = 'let @c = ' . string(@c)

"| Было (ASCII) | Нужно писать | Что это   | Команда для замены
"| ------------ | ------------ | --------- | ----------
"| `\13`        | `\<CR>`      | Enter     |  :s/\%x0d/\\<CR>/g 
"| `\27`        | `\<Esc>`     | Esc       |  :s/\%x1b/\\<Esc>/g
"| `\9`         | `\<Tab>`     | Tab       |  :s/\%x09/\\<Tab>/g
"| `\8`         |   не писать  | Backspace |  
"| `\32`        | пробел       | Space     |  :s/\%x20/\\<Space>/g

let @c = "iclass\<Space>:\<CR>def __init__(self):\<Esc>kkhhi"
let @w = "iprint(\"\")\<Esc>hi"

