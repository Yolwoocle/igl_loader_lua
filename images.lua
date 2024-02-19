local function load_image(name)
	local im = love.graphics.newImage("assets/img/"..name)
	im:setFilter("nearest", "nearest")
	return im
end

local img = {
    bg_bird = load_image("bg_bird.png"),
    bg_bugs = load_image("bg_bugs.png"),

    fg_bird = load_image("fg_bird.png"),
    fg_bugs = load_image("fg_bugs.png"),

	logo_bird = load_image("logo_bird.png"),
	logo_bugs = load_image("logo_bugs.png"),

	btn_lr = load_image("btn_lr.png"),
	btn_mouse = load_image("btn_mouse.png"),
}

return img