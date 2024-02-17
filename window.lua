require "util"
local Class = require "class"

local Window = Class:inherit()

function Window:init(side, image_bg, image_logo, logo_scale, image_fg)
    SCREEN_XCENTER = SCREEN_WIDTH*0.5
    SLIDE_AMOUNT = SCREEN_WIDTH*0.25

    self.side = side
    self.image_bg = image_bg
    self.image_fg = image_fg
    self.image_logo = image_logo

    self.canvas_w, self.canvas_h = SCREEN_XCENTER + SLIDE_AMOUNT, SCREEN_HEIGHT
    self.canvas = love.graphics.newCanvas(self.canvas_w, self.canvas_h)
    if side == "l" then
        self.def_canvas_x = -SLIDE_AMOUNT
    else
        self.def_canvas_x = SCREEN_XCENTER
    end
    self.canvas_x = self.def_canvas_x
    self.canvas_target_x = self.canvas_x

    self.logo_x = 0
    self.logo_y = SCREEN_HEIGHT*0.33
    self.logo_scale = logo_scale

    self.target_logo_x = self.logo_x
    self.target_logo_y = self.logo_y

    self.lightness = 1.0
    self.target_lightness = 1.0

    self.direction = self.side == "l" and 1 or -1
end

function Window:update(dt)
    self.canvas_x = lerp(self.canvas_x, self.canvas_target_x, 0.2)
    self.lightness = lerp(self.lightness, self.target_lightness, 0.2)
    self.logo_x = lerp(self.logo_x, self.target_logo_x, 0.2)
    self.logo_y = lerp(self.logo_y, self.target_logo_y, 0.2)
end

function Window:draw()
    love.graphics.setCanvas(self.canvas)
    
    love.graphics.clear(0, 0, 0)
    -- love.graphics.setBlendMode("alpha", "premultiplied")

    -- Background
    local p = 0.25
    local parallax = (self.def_canvas_x - self.canvas_x) * p - SLIDE_AMOUNT*p
    love.graphics.draw(self.image_bg, parallax, 0, 0, 1/1.5)
    
    -- Foreground
    local fg_w, fg_h = self.image_fg:getDimensions()
    love.graphics.draw(self.image_fg, self.logo_x, SCREEN_HEIGHT*0.66, 0, 0.85, 0.85, fg_w/2, fg_h/2)

    -- Logo
    local logo_w, logo_h = self.image_logo:getDimensions()
    love.graphics.draw(self.image_logo, self.logo_x, self.logo_y, 0, self.logo_scale, self.logo_scale, logo_w/2, logo_h/2)

    -- Darken
    love.graphics.setColor(0, 0, 0, 1.0-self.lightness)
    love.graphics.rectangle("fill", 0, 0, self.canvas_w, self.canvas_h)
    love.graphics.setColor(1, 1, 1, 1.0)
    
    love.graphics.setCanvas()

    love.graphics.draw(self.canvas, self.canvas_x, 0)
end

function Window:set_focus(focus_mode)
    local d = self.direction

    if focus_mode == "+" then
        self.canvas_target_x = self.def_canvas_x + d*SLIDE_AMOUNT
        self.target_lightness = 1.0
        self.target_logo_x = (self.side == "l" and self.canvas_w or 0) - self.direction * self.canvas_w * 0.5
    elseif focus_mode == "-" then
        self.canvas_target_x = self.def_canvas_x - d*SLIDE_AMOUNT
        self.target_lightness = 0.4
        self.target_logo_x = (self.side == "l" and self.canvas_w or 0) - self.direction * SCREEN_WIDTH * 0.125
    else
        self.canvas_target_x = self.def_canvas_x
        self.target_lightness = 1.0
        self.target_logo_x = (self.side == "l" and self.canvas_w or 0) - self.direction * SCREEN_WIDTH * 0.25
    end
end

return Window