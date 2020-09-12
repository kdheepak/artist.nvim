vim = vim
local api = vim.api
local fn = vim.fn

local STATE = {
    artist_mode = false,
}

local CHARS = {
    vertical = '│',
    horizontal = '─',
    down_and_right = '┌',
    down_and_left = '┐',
    up_and_right = '└',
    up_and_left = '┘',
}

local function set_chars_to_light()
    CHARS['vertical'] = '│'
    CHARS['horizontal'] = '─'
end

local function artist_noop()
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
    return char
end

local function artist_drag()
    local row, col = current_cursor_pos()
    if col == STATE['last_col'] then
        -- We moved in a column. We need to find out where we came from.
        if col == STATE['last_last_col'] then
            -- we are moving in a straight line vertically
            vim.cmd("normal! r" .. CHARS["vertical"])
        else
            -- We took a turn
            -- We need to fix the corner now
            if STATE['last_last_col'] > col and STATE['last_row'] < row then
                -- If we came from the right and moved down
                vim.cmd("normal! kr" .. CHARS["down_and_right"] .. "jr" .. CHARS["vertical"])
            elseif STATE['last_last_col'] > col and STATE['last_row'] > row then
                -- If we came from the right and moved up
                vim.cmd("normal! jr" .. CHARS["up_and_right"] .. "kr" .. CHARS["vertical"])
            elseif STATE['last_last_col'] < col and STATE['last_row'] < row then
                -- If we came from the left and moved down
                vim.cmd("normal! kr" .. CHARS["down_and_left"] .. "jr" .. CHARS["vertical"])
            elseif STATE['last_last_col'] < col and STATE['last_row'] > row then
                -- If we came from the left and moved up
                vim.cmd("normal! jr" .. CHARS["up_and_left"] .. "kr" .. CHARS["vertical"])
            end
        end
    else
        -- We moved in a row. We need to find out where we came from.
        if row == STATE['last_last_row'] then
            -- we are moving in a straight line horizontally
            vim.cmd("normal! r" .. CHARS["horizontal"])
        else
            -- We took a turn
            -- We need to fix the corner now
            if STATE['last_last_row'] > row and STATE['last_col'] < col then
                -- If we came from the bottom and moved right
                vim.cmd("normal! hr" .. CHARS["down_and_right"] .. "lr" .. CHARS["horizontal"])
            elseif STATE['last_last_row'] > row and STATE['last_col'] > col then
                -- If we came from the bottom and moved left
                vim.cmd("normal! lr" .. CHARS["down_and_left"] .. "hr" .. CHARS["horizontal"])
            elseif STATE['last_last_row'] < row and STATE['last_col'] < col then
                -- If we came from the top and moved right
                vim.cmd("normal! hr" .. CHARS["up_and_right"] .. "lr" .. CHARS["horizontal"])
            elseif STATE['last_last_row'] < row and STATE['last_col'] > col then
                -- If we came from the top and moved left
                vim.cmd("normal! lr" .. CHARS["up_and_left"] .. "hr" .. CHARS["horizontal"])
            end
        end

    end
    STATE['last_last_row'] = STATE['last_row']
    STATE['last_last_col'] = STATE['last_col']
    STATE['last_row'] = row
    STATE['last_col'] = col
end

local function artist_click(char)
    if char == nil then char = CHARS["horizontal"] end
    local row, col = current_cursor_pos()
    STATE['last_last_row'] = row
    STATE['last_last_col'] = col
    STATE['last_row'] = row
    STATE['last_col'] = col
    -- vim.cmd("normal! r" .. char)
end

local function artist_on()
    STATE['virtualedit'] = vim.o.virtualedit
    STATE['mousemodel'] = vim.o.mousemodel
    STATE['mouse'] = vim.o.mouse
    vim.cmd 'setl virtualedit=all'
    vim.cmd 'setl mousemodel=extend'
    vim.cmd 'setl mouse=a'

    vim.cmd "nnoremap <buffer> <silent> <LeftMouse> <LeftMouse>:lua require'artist'.artist_click()<CR>"
    vim.cmd "nnoremap <buffer> <silent> <LeftDrag> <LeftMouse>:lua require'artist'.artist_drag()<CR>"

    print('Artist mode: ON')
end

local function artist_off()
    if STATE['virtualedit'] ~= nil then vim.o.virtualedit = STATE['virtualedit'] end
    if STATE['mousemodel'] ~= nil then vim.o.mousemodel = STATE['mousemodel'] end
    if STATE['mouse'] ~= nil then vim.o.mouse= STATE['mouse'] end

    vim.cmd "nunmap <buffer> <LeftMouse>"
    vim.cmd "nunmap <buffer> <LeftDrag>"
    print('Artist mode: OFF')
end

local function artist_toggle()

    if STATE['artist_mode'] then
        STATE['artist_mode'] = false
        artist_off()
    else
        STATE['artist_mode'] = true
        artist_on()
    end

end

return {
    artist_toggle = artist_toggle,
    artist_on = artist_on,
    artist_off = artist_off,
    artist_click = artist_click,
    artist_drag = artist_drag,
}
