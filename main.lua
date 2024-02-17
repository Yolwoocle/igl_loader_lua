
local Game = require "game"

SCREEN_WIDTH = -1
SCREEN_HEIGHT = -1

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

GAME = nil
FONT = nil

function love.load(arg)
    love.window.setTitle("Indie Game Lyon Launcher")
	love.window.setMode(0, 0, {fullscreen = true, vsync = true})

	SCREEN_WIDTH = love.graphics.getWidth()
	SCREEN_HEIGHT = love.graphics.getHeight()

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = true, vsync = true})

    GAME = Game:new()

	FONT = love.graphics.newFont("assets/font/Lexend-ExtraBold.ttf", 64)
	love.graphics.setFont(FONT)
end

function love.update(dt)
	GAME:update(dt)
end

function love.draw()
	GAME:draw()
end

function love.keypressed(key, scancode, isreapeat)
    GAME:keypressed(key, scancode, isreapeat)
end

function love.mousepressed(x, y, button, istouch, presses)
	GAME:mousepressed(x, y, button)
end

function love.quit()
	GAME:quit()
end

function love.conf(t)
	t.console = true
end