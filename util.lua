function get_file_contents(filename)
    local file = love.filesystem.newFile(filename)
    file:open("r")
    local data = file:read()
    file:close()

    if data == nil then
        return ""
    end
    return data
end

function lerp(a, b, t)
    return a + (b-a) * t
end

function print_centered(text, x, y)
    assert(FONT ~= nil, "font is nil")
    local w = FONT:getWidth(text)
    love.graphics.print(text, x, y, 0, 1, 1, w/2)
end

function print_centered_outline(text, x, y, o)
    love.graphics.setColor(0, 0, 0, 1)
    for ix = -o, o do
        for iy = -o, o do
            if ix*ix + iy*iy <= o*o then
                print_centered(text, x+ix, y+iy)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    print_centered(text, x, y)

    love.graphics.setColor(1, 1, 1, 1)
end