vim = vim
local api = vim.api
local fn = vim.fn

local STATE = {
    artist_mode = false,
}

local CHARS = {}

local function set_chars_to_light_square(chars)
    chars['vertical'] = '│'
    chars['horizontal'] = '─'
    chars['down_and_right'] = '┌'
    chars['down_and_left'] = '┐'
    chars['up_and_right'] = '└'
    chars['up_and_left'] = '┘'
    chars['vertical_and_left'] = '┤'
    chars['vertical_and_right'] = '├'
    chars['down_and_horizontal'] = '┬'
    chars['up_and_horizontal'] = '┴'
    chars['vertical_and_horizontal'] = '┼'
end

local function set_chars_to_light_arc(chars)
    chars['vertical'] = '│'
    chars['horizontal'] = '─'
    chars['down_and_right'] = '╭'
    chars['down_and_left'] = '╮'
    chars['up_and_right'] = '╰'
    chars['up_and_left'] = '╯'
    chars['vertical_and_left'] = '┤'
    chars['vertical_and_right'] = '├'
    chars['down_and_horizontal'] = '┬'
    chars['up_and_horizontal'] = '┴'
    chars['vertical_and_horizontal'] = '┼'
end

local function set_chars_to_heavy_square(chars)
    chars['vertical'] = '┃'
    chars['horizontal'] = '━'
    chars['down_and_right'] = '┏'
    chars['down_and_left'] = '┓'
    chars['up_and_right'] = '┗'
    chars['up_and_left'] = '┛'
    chars['vertical_and_left'] = '┫'
    chars['vertical_and_right'] = '┣'
    chars['down_and_horizontal'] = '┳'
    chars['up_and_horizontal'] = '┻'
    chars['vertical_and_horizontal'] = '╋'
end

local function set_chars_to_double_square(chars)
    chars['vertical'] = '║'
    chars['horizontal'] = '═'
    chars['down_and_right'] = '╔'
    chars['down_and_left'] = '╗'
    chars['up_and_right'] = '╚'
    chars['up_and_left'] = '╝'
    chars['vertical_and_left'] = '╣'
    chars['vertical_and_right'] = '╠'
    chars['down_and_horizontal'] = '╦'
    chars['up_and_horizontal'] = '╩'
    chars['vertical_and_horizontal'] = '╬'
end


local function current_cursor_pos()
    local _, row, _, _ = unpack(vim.fn.getpos("."))
    local col = vim.fn.virtcol(".")
    return row, col
end

local function find_char(s, i)
    local index = 0
    for character in string.gmatch(s, "([%z\1-\127\194-\244][\128-\191]*)") do
        index = index + 1
        if index == i then
            return character
        end
    end
    return nil
end

local function char_at_pos(row, col)
    if row == nil then row = "." end
    if col == nil then col = vim.fn.virtcol(".") end
    local s = vim.fn.getline(row)
    local char = find_char(s, col)
    if char == nil then char = '' end
    return char
end

local function has_value(tabl, value)
    for _, v in pairs(tabl) do
        if v == value then
            return true
        end
    end
    return false
end

local function is_valid_above(char)
    return has_value(
        {
            CHARS['down_and_right'],
            CHARS['down_and_left'],
            CHARS['down_and_horizontal'],
            CHARS['vertical_and_left'],
            CHARS['vertical_and_right'],
            CHARS['vertical'],
            CHARS['vertical_and_horizontal']
        }, char
    )
end

local function is_valid_below(char)
    return has_value(
        {
            CHARS['up_and_right'],
            CHARS['up_and_left'],
            CHARS['up_and_horizontal'],
            CHARS['vertical_and_left'],
            CHARS['vertical_and_right'],
            CHARS['vertical'],
            CHARS['vertical_and_horizontal'],
        }, char
    )
end

local function is_valid_right(char)
    return has_value(
        {
            CHARS['down_and_left'],
            CHARS['up_and_left'],
            CHARS['vertical_and_left'],
            CHARS['down_and_horizontal'],
            CHARS['up_and_horizontal'],
            CHARS['horizontal'],
            CHARS['vertical_and_horizontal'],
        }, char
    )
end

local function is_valid_left(char)
    return has_value(
        {
            CHARS['down_and_right'],
            CHARS['up_and_right'],
            CHARS['vertical_and_right'],
            CHARS['down_and_horizontal'],
            CHARS['up_and_horizontal'],
            CHARS['horizontal'],
            CHARS['vertical_and_horizontal'],
        }, char
    )
end

local function char_to_insert(row, col, default)

    if default == nil then default = "" end

    local c = default

    local current = char_at_pos(row, col)
    local below = char_at_pos(row + 1, col)
    local right = char_at_pos(row, col + 1)
    local above =  char_at_pos(row - 1, col)
    local left =  char_at_pos(row, col - 1)

    if is_valid_above(above) and is_valid_below(below) and is_valid_left(left) and is_valid_right(right) then
        c = CHARS['vertical_and_horizontal']
    elseif is_valid_below(below) and is_valid_above(above) and is_valid_right(right) then
        c = CHARS['vertical_and_right']
    elseif is_valid_below(below) and is_valid_above(above) and is_valid_left(left) then
        c = CHARS['vertical_and_left']
    elseif is_valid_above(above) and is_valid_left(left) and is_valid_right(right) then
        c = CHARS['up_and_horizontal']
    elseif is_valid_below(below) and is_valid_left(left) and is_valid_right(right) then
        c = CHARS['down_and_horizontal']
    elseif is_valid_above(above) and is_valid_right(right) then
        c = CHARS['up_and_right']
    elseif is_valid_above(above) and is_valid_left(left) then
        c = CHARS['up_and_left']
    elseif is_valid_below(below) and is_valid_right(right) then
        c = CHARS['down_and_right']
    elseif is_valid_below(below) and is_valid_left(left) then
        c = CHARS['down_and_left']
    elseif is_valid_below(below) and is_valid_above(above) then
        c = CHARS['vertical']
    elseif is_valid_left(left) and is_valid_right(right) then
        c = CHARS['horizontal']
    end

    return c
end


local function artist_freehand_drag()

    local row, col = current_cursor_pos()

    if col == STATE['last_col'] then
        -- We moved in a column. We need to find out where we came from.
        vim.cmd("normal! r" .. char_to_insert(row, col, CHARS["vertical"]))
        if col ~= STATE['last_last_col'] then
            -- We took a turn
            -- We need to fix the corner now
            if STATE['last_last_col'] == col + 1 and STATE['last_row'] == row - 1 then
                -- If we came from the right and moved down
                vim.cmd("normal! kr" .. char_to_insert(row - 1, col, CHARS['down_and_right']) .. "jr" .. CHARS["vertical"])
            elseif STATE['last_last_col'] == col + 1 and STATE['last_row'] == row + 1 then
                -- If we came from the right and moved up
                vim.cmd("normal! jr" .. char_to_insert(row + 1, col, CHARS['up_and_right']) .. "kr" .. CHARS["vertical"])
            elseif STATE['last_last_col'] == col - 1 and STATE['last_row'] == row - 1 then
                -- If we came from the left and moved down
                vim.cmd("normal! kr" .. char_to_insert(row - 1, col, CHARS['down_and_left']) .. "jr" .. CHARS["vertical"])
            elseif STATE['last_last_col'] == col - 1 and STATE['last_row'] == row + 1 then
                -- If we came from the left and moved up
                vim.cmd("normal! jr" .. char_to_insert(row + 1, col, CHARS['up_and_left']) .. "kr" .. CHARS["vertical"])
            end
        end
    else
        -- We moved in a row. We need to find out where we came from.
        vim.cmd("normal! r" .. char_to_insert(row, col, CHARS["horizontal"]))
        if row ~= STATE['last_last_row'] then
            -- We took a turn
            -- We need to fix the corner now
            if STATE['last_last_row'] == row + 1 and STATE['last_col'] == col - 1 then
                -- If we came from the bottom and moved right
                vim.cmd("normal! hr" .. char_to_insert(row, col - 1, CHARS['down_and_right']) .. "lr" .. CHARS["horizontal"])
            elseif STATE['last_last_row'] == row + 1 and STATE['last_col'] == col + 1 then
                -- If we came from the bottom and moved left
                vim.cmd("normal! lr" .. char_to_insert(row, col + 1, CHARS['down_and_left']) .. "hr" .. CHARS["horizontal"])
            elseif STATE['last_last_row'] == row - 1 and STATE['last_col'] == col - 1 then
                -- If we came from the top and moved right
                vim.cmd("normal! hr" .. char_to_insert(row, col - 1, CHARS['up_and_right']) .. "lr" .. CHARS["horizontal"])
            elseif STATE['last_last_row'] == row - 1 and STATE['last_col'] == col + 1 then
                -- If we came from the top and moved left
                vim.cmd("normal! lr" .. char_to_insert(row, col + 1, CHARS['up_and_left']) .. "hr" .. CHARS["horizontal"])
            end
        end

    end
    STATE['last_last_row'] = STATE['last_row']
    STATE['last_last_col'] = STATE['last_col']
    STATE['last_row'] = row
    STATE['last_col'] = col
end


local function artist_freehand_click(char)

    STATE['last_last_row'] = row
    STATE['last_last_col'] = col
    STATE['last_row'] = row
    STATE['last_col'] = col

    local row, col = current_cursor_pos()

    if char == nil then char = char_at_pos(row, col) end

    vim.cmd("normal! r" .. char_to_insert(row, col, char))
end

local function artist_freehand_on()
    STATE['virtualedit'] = vim.o.virtualedit
    STATE['mousemodel'] = vim.o.mousemodel
    STATE['mouse'] = vim.o.mouse
    vim.cmd 'setl virtualedit=all'
    vim.cmd 'setl mousemodel=extend'
    vim.cmd 'setl mouse=a'

    vim.cmd "nnoremap <buffer> <silent> <LeftClick> <LeftMouse>:lua require'artist'.artist_freehand_click()<CR>"
    vim.cmd "nnoremap <buffer> <silent> <LeftDrag> <LeftMouse>:lua require'artist'.artist_freehand_drag()<CR>"

    print('Artist mode: ON')
end

local function artist_freehand_off()
    if STATE['virtualedit'] ~= nil then vim.o.virtualedit = STATE['virtualedit'] end
    if STATE['mousemodel'] ~= nil then vim.o.mousemodel = STATE['mousemodel'] end
    if STATE['mouse'] ~= nil then vim.o.mouse= STATE['mouse'] end

    vim.cmd "nunmap <buffer> <LeftRelease>"
    vim.cmd "nunmap <buffer> <LeftDrag>"
    print('Artist mode: OFF')
end

local function artist_freehand_toggle()

    if STATE['artist_freehand_mode'] then
        STATE['artist_freehand_mode'] = false
        artist_freehand_off()
    else
        STATE['artist_freehand_mode'] = true
        artist_freehand_on()
    end

end

local function artist_use_char_set(char_set_type)
    if char_set_type == 'light' then
        set_chars_to_light_square(CHARS)
    elseif char_set_type == 'arc' then
        set_chars_to_light_arc(CHARS)
    elseif char_set_type == 'heavy' then
        set_chars_to_heavy_square(CHARS)
    elseif char_set_type == 'double' then
        set_chars_to_double_square(CHARS)
    else
        set_chars_to_light_square(CHARS)
    end
end

local function artist_init()
    artist_use_char_set()
end

artist_init()

return {
    artist_init = artist_init,
    artist_use_char_set = artist_use_char_set,
    artist_freehand_toggle = artist_freehand_toggle,
    artist_freehand_on = artist_freehand_on,
    artist_freehand_off = artist_freehand_off,
    artist_freehand_click = artist_freehand_click,
    artist_freehand_drag = artist_freehand_drag,
}
