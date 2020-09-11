vim = vim
local api = vim.api
local fn = vim.fn

local settings = {
    artist_mode = false,
    virtualedit = nil,
}


local function artist_on()
    settings['virtualedit'] = vim.o.virtualedit
    vim.cmd 'setl virtualedit=all'
    print('Artist mode: ON')
end

local function artist_off()
    if settings['virtualedit'] ~= nil then
        vim.o.virtualedit = settings['virtualedit']
    end
    print('Artist mode: OFF')
end

local function artist_toggle()

    if settings['artist_mode'] then
        settings['artist_mode'] = false
        artist_off()
    else
        settings['artist_mode'] = true
        artist_on()
    end

end

return {
    artist_toggle = artist_toggle,
    artist_on = artist_on,
    artist_off = artist_off,
}
