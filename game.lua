require "util"
local Class = require "class"
local Window = require "window"
local img = require "images"

local Game = Class:inherit()

local thread_code = get_file_contents("thread.lua")
local MOUSE_DEADZONE = 100
local MOUSE_MODE_MIN_SPEED = 4

function Game:init()
	self.thread = nil

	self.mx, self.my = love.mouse.getPosition()
	self.prev_mx = self.mx
	self.prev_my = self.my
	self.selection = 0

	self.sel_windows = {
		Window:new("l", img.bg_bird, img.logo_bird, 5/6, img.fg_bird),
		Window:new("r", img.bg_bugs, img.logo_bugs, 2/3, img.fg_bugs)
	}

	self.input_mode = "keyboard"
	self.is_launched = false

	self.t = 0.0
end

function Game:update(dt)
	self.t = self.t + dt

	-- activate mouse mode if mouse moves
	self.mx, self.my = love.mouse.getPosition()
	local dx, dy = (self.prev_mx - self.mx), (self.prev_my - self.my)
	if dx*dx + dy*dy > MOUSE_MODE_MIN_SPEED*MOUSE_MODE_MIN_SPEED then
		self.input_mode = "mouse"
	end
	
	-- update selection 
	if self.input_mode == "mouse" then
		if self.mx <= SCREEN_WIDTH*0.5 - MOUSE_DEADZONE then
			self.selection = 0
		elseif self.mx >= SCREEN_WIDTH*0.5 + MOUSE_DEADZONE then
			self.selection = 2
		else
			self.selection = 1
		end
	end
	
	-- default when running
	if self.is_launched then
		self.selection = 1
		self.input_mode = "keyboard"
	end
	
	-- update windows
	if self.selection == 0 then
		self.sel_windows[1]:set_focus("+")
		self.sel_windows[2]:set_focus("-")
	elseif self.selection == 2 then
		self.sel_windows[1]:set_focus("-")
		self.sel_windows[2]:set_focus("+")
	else
		self.sel_windows[1]:set_focus("0")
		self.sel_windows[2]:set_focus("0")
	end

	-- update mouse visibility
	love.mouse.setVisible(self.input_mode == "mouse")

	-- recieve thread info
	local info = love.thread.getChannel('info'):pop()
    if info then
        print("[main] ".. info)
		if info == "finished" then
			self.is_launched = false
		end
    end
	
	-- update windows
	for k,window in pairs(self.sel_windows) do
		window:update(dt)
	end

	-- old mouse position 
	self.prev_mx = self.mx
	self.prev_my = self.my
end

function Game:draw()
	for k,window in pairs(self.sel_windows) do
		window:draw()
	end

	print_centered_outline("Select a game", SCREEN_XCENTER, 40, 6)
	
	if self.is_launched then
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		love.graphics.setColor(1, 1, 1, 1.0)
		print_centered_outline("Game running...", SCREEN_XCENTER, SCREEN_HEIGHT - 90, 6)
	end
end

function Game:keypressed(key, scancode, isreapeat)
	if scancode == "left" or scancode == "a" then
		self.selection = math.max(self.selection - 1, 0)
		self.input_mode = "keyboard"
	elseif scancode == "right" or scancode == "d" then
		self.selection = math.min(self.selection + 1, 2)
		self.input_mode = "keyboard"
	elseif scancode == "return" or scancode == "space" or scancode == "c" then
		self:run_selection()
	end
end

function Game:mousepressed(x, y, button)
	if button == 1 then
		self:run_selection()
	end
end

function Game:run_selection()
	if self.is_launched then
		return
	end

	local selection = self.selection
	local launched = false
	if selection == 0 then
		self:lauch_experience("experiences\\bwg\\bwg_v2.exe -windowed 0")
		launched = true
	elseif selection == 2 then
		self:lauch_experience("experiences\\bugscraper\\bugscraper.exe")
		launched = true
	end

	if launched then
		self.is_launched = true
	end
end

function Game:lauch_experience(command)
	self.thread = love.thread.newThread(thread_code)
	self.thread:start(command)
end

function Game:quit()
    
end

return Game