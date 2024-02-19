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

	self.stats = {}
	self:read_files()

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

	-- text	
	love.graphics.setFont(FONT)
	print_centered_outline("Sélectionnez un jeu", SCREEN_XCENTER, 40, 6)
	draw_centered(img.btn_lr, SCREEN_XCENTER - img.btn_lr:getWidth() + 10, 150)
	draw_centered(img.btn_mouse, SCREEN_XCENTER + img.btn_mouse:getWidth(), 150)
	love.graphics.setFont(FONT_SM)
	print_centered_outline("ou", SCREEN_XCENTER, 130, 4)
	
	-- launched	
	if self.is_launched then
		love.graphics.setColor(0, 0, 0, 0.8)
		love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
		love.graphics.setColor(1, 1, 1, 1.0)
		love.graphics.setFont(FONT_SM)
		print_centered_outline("Partie en cours...", SCREEN_XCENTER, SCREEN_HEIGHT - 90, 6)
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

function Game:read_files()
	self.stats = {}
	self:read_stats_bwg()
end

function Game:read_stats_bwg()
	local bird_stats = {
		avg_wagon = 0,
		
		avg_kills = 0,
		total_kills = 0,
		
		avg_time = 0,
		total_time = 0,

		n_keyboard = 0,
		n_mouse = 0,
		n_players = 0,

		bird_choices = {0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0}
	}

	local player_n = 0

	local new_session = function()
		return {
			kills = 0,
			time = 0,
			timef = {},
			wagon = 0,
			keyboard = false,
			bird = 1,
			systime = {},
		}
	end
	local bird_sessions = {new_session()}
	local session_i = 1
	for line in love.filesystem.lines("bwg_stats.txt") do
		-- table.insert(scores, tonumber(line))
		local pair = split(line, " ")
		if pair ~= nil and #pair >= 2 then
			local key, value = pair[1], pair[2]
			self:stats_process_pair_bwg(bird_sessions[session_i], key, value)
		end

		if #line > 0 and line:sub(1, 1) == "*" then
			session_i = session_i + 1
			bird_sessions[session_i] = new_session()
			player_n = player_n + 1
		end
	end
	table.remove(bird_sessions)
	print("player_n "..player_n)

	-- global stats
	for k,session in pairs(bird_sessions) do
		bird_stats.avg_wagon = bird_stats.avg_wagon + session.wagon
		
		bird_stats.total_kills = bird_stats.total_kills + session.kills
		
		bird_stats.total_time = bird_stats.total_time + session.time
		
		if session.keyboard then
			bird_stats.n_keyboard = bird_stats.n_keyboard + 1
		else
			bird_stats.n_mouse = bird_stats.n_mouse + 1
		end
		
		bird_stats.bird_choices[session.bird] = bird_stats.bird_choices[session.bird] + 1
	end
	bird_stats.n_players = player_n
	bird_stats.avg_kills = bird_stats.total_kills / bird_stats.n_players
	bird_stats.avg_time = bird_stats.total_time / bird_stats.n_players

	print_table(bird_stats)

	self.stats.bird = bird_stats
end

function Game:stats_process_pair_bwg(cur_session, key, value)
	-- kills 0
	-- time 0:06.3
	-- wagon 1/7
	-- x 205.247
	-- keyboard false
	-- bird 117
	-- systime 19/2_10:59:17
	-- 
	if key == nil or value == nil then
		return 
	end

	if key == "kills" then
		local n = tonumber(value:sub(1, 1))
		if n then
			cur_session.kills = n
		end

	elseif key == "time" then
		local splitvals = split(value,":")
		if splitvals and splitvals[1] and splitvals[2] then
			local min, sec = tonumber(splitvals[1]), tonumber(splitvals[2])
			cur_session.time = min*60 + sec
			cur_session.timef = { min = min, sec = sec }
		end		

	elseif key == "wagon" then
		local splitvals = split(value,"/")
		if splitvals and splitvals[1] then
			local wagon = tonumber(splitvals[1])
			cur_session.wagon = cur_session.wagon + wagon - 1
		end

	elseif key == "x" then
		local x = tonumber(value)
		if x then
			cur_session.wagon = cur_session.wagon + (x / (128*4))
		end
		
	elseif key == "keyboard" then
		local kb = (value == "true")
		cur_session.keyboard = kb

	elseif key == "bird" then
		local b = tonumber(value)
		if b then
			cur_session.bird = b - 112 + 1
		end

	elseif key == "systime" then
		local splitval = split(value, "_")
		local date = split(splitval[1], "/")
		local time = split(splitval[2], ":")
		cur_session.systime = {
			day = date[1],
			month = date[2],

			hour = time[1],
			min = time[2],
			sec = time[3],
		}
	end
end

return Game