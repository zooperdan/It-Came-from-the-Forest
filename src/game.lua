local Messages = require "messages"
local Renderer = require "renderer"
local Assets = require "assets"
local Party = require "party"
local Level = require "level"
local Atlases = require "atlases"
local Enemy = require "enemy"

Timer = require "libs/timer"
Button = require "button"

local GlobalVariables = require "globalvariables"
local ItemTemplates = require "itemtemplates"

assets = Assets:new()
renderer = Renderer:new()
level = Level:new()
atlases = Atlases:new()
party = Party:new()
messages = Messages:new()
globalvariables = GlobalVariables:new()

local Game = class('Game')

itemtemplates = ItemTemplates:new()

function Game:initialize()

	math.randomseed(os.time())

	gameState = GameStates.INIT
	subState = SubStates.IDLE
	self.footStepIndex = 1
	love.graphics.setDefaultFilter( "nearest", "nearest", 0)
	self.isFading = false
	self.quickstart = true
	
end

function Game:init()

	love.mouse.setGrabbed(true)
	love.mouse.setVisible(false)
	
	self.isFullscreen = love.window.fullscreen
	self.canvas = love.graphics.newCanvas(screen.width, screen.height)

	assets:load()
	
	renderer:init(self)
	
	if self.quickstart then
		gameState = GameStates.LOADING_LEVEL
		Game.isFading = false
		assets:stopMusic("mainmenu")
		Game:loadArea(startingArea)
	else 
		assets:playMusic("buildup")
		
		gameState = GameStates.BUILDUP1

		Timer.script(function(wait)
			Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
			wait(4)
			Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', buildUpStep2)
		end)
	end
	
end

function Game:update(dt)


	if gameState == GameStates.EXPLORING then
		
		if subState == SubStates.IDLE then
		
			if self.enemies then
				for key,value in pairs(self.enemies) do
					self.enemies[key]:update(dt)
				end
			end
			
			party:update(dt)

		end
		
	end
	
	if gameState ~= GameStates.INIT then
		renderer:update(dt)
	end
	
	if gameState == GameStates.MAIN_MENU then
		if assets.music["mainmenu"] then
			assets.music["mainmenu"]:setVolume(fadeMusicVolume.v)
		end
	end
	
	if gameState == GameStates.LOADING_LEVEL then
		if assets.music[level.data.tileset] then
			assets.music[level.data.tileset]:setVolume(fadeMusicVolume.v)
		end
	end	
	
	love.graphics.setColor(fadeColor)
	
	Timer.update(dt)
	
end

function Game:handleMousePressed(x, y, button, istouch)
	
	if gameState == GameStates.INIT or gameState == GameStates.LOADING_LEVEL then
		return
	end
	
	if button == 1 then
	
		if gameState == GameStates.BUILDUP1 or gameState == GameStates.BUILDUP2 or gameState == GameStates.BUILDUP3 or gameState == GameStates.BUILDUP4 then
			self:jumpToMainmenu()
			return
		end	
	
		if gameState == GameStates.MAIN_MENU and self.isFading == false then
			self:startGame()
			return
		end	
	
		if gameState == GameStates.EXPLORING then
			
			if subState == SubStates.IDLE then
				
				if intersect(x, y, 278, 321, 34, 34) then
					party:attackWithMelee(self.enemies)
				end
				
				if intersect(x, y, 326, 321, 34, 34) then
					subState = SubStates.SELECT_SPELL
					renderer:showSpellList()
				end
				
				if intersect(x, y, 239, 325, 30, 30) then
					party:usePotion(1)
				end
				
				if intersect(x, y, 372, 325, 30, 30) then
					party:usePotion(2)
				end

				if intersect(x, y, 19, 321, 34, 34) then
					if not renderer:inventoryShowing() then
						renderer:showInventory(true)
						return
					end
				end
				
				if intersect(x, y, 587, 321, 34, 34) then
					if not renderer:automapperShowing() then
						renderer:showAutomapper(true)
						return
					end				
				end
				
			end
			
		end
	
	end
	
	if button == 3 then
		local state = not love.mouse.isGrabbed()   -- the opposite of whatever it currently is
		love.mouse.setGrabbed(state)
	end
   
	renderer:handleMousePressed(x, y, button)
	
end


function Game:handleInput(key)

	if gameState == GameStates.INIT or gameState == GameStates.LOADING_LEVEL then
		return
	end

	local key = string.lower(key)

	-- COMMON

    if key == 'f1' then
        globalvariables:dump()
    end
	
	if key == "f2" then
		globalvariables:clear()
		messages:clear()
		self:loadArea("area1")
	end
	
    if key == 'return' then
		if love.keyboard.isDown("lalt") then
			love.window.setFullscreen(not love.window.getFullscreen())
		end
    end

	if gameState == GameStates.FATAL_ERROR then

		love.event.quit()

		return
	end
	
	if key == 'escape' then
		love.event.quit()
	end
	
	if gameState == GameStates.MAIN_MENU and self.isFading == false then

		if key == 'c' then
			gameState = GameStates.CREDITS
			return
		end
		
	end
			
	if gameState == GameStates.CREDITS then

		if key == 'c' then
			gameState = GameStates.MAIN_MENU
			return
		end
		
	end
	
	if gameState == GameStates.EXPLORING then

		if subState == SubStates.IDLE then

			if key == 'left' or key == 'kp7' or key == 'q' then
				party.direction = party.direction - 1
				if party.direction < 0 then
					party.direction = 3
				end
				renderer:flipGround()
				renderer:flipSky()
				self:playFootstepSound()
				return
			end

			if key == 'right' or key == 'kp9' or key == 'e' then
				party.direction = party.direction + 1
				if party.direction > 3 then
					party.direction = 0
				end
				renderer:flipGround()
				renderer:flipSky()
				self:playFootstepSound()
				return
			end
			
			if key == 'up' or key == 'kp8' or key == 'w' then
				self:moveForward()
				return
			end
			
			if key == 'down' or key == 'kp2' or key == 's' then
				self:moveBackward()
				return
			end
			
			if key == 'kp4' or key == 'a' then
				self:strafeLeft()
				return
			end
			
			if key == 'kp6' or key == 'd' then
				self:strafeRight()
				return
			end			

			if key == 'i' then
				if not renderer:inventoryShowing() then
					renderer:showInventory(true)
					return
				end
			end	
			
			if key == 'm' then
				if not renderer:automapperShowing() then
					renderer:showAutomapper(true)
					return
				end				
			end	
			
		end

		renderer:handleInput(key)
		
	end
	
end

function Game:playFootstepSound()

	assets:playSound(assets.sfx.footsteps[level.data.tileset][self.footStepIndex])

	self.footStepIndex = self.footStepIndex + 1
	if self.footStepIndex > #assets.sfx.footsteps.city then
		self.footStepIndex = 1
	end
	
end

function Game:moveForward()

	local x,y = party.x,party.y

	if party.direction == 0 then
		y = party.y - 1
	elseif party.direction == 1 then
		x = party.x + 1
	elseif party.direction == 2 then
		y = party.y + 1
	elseif party.direction == 3 then
		x = party.x - 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end
	
	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:playFootstepSound()

end

function Game:moveBackward()

	local x,y = party.x,party.y

	if party.direction == 0 then
		y = party.y + 1
	elseif party.direction == 1 then
		x = party.x - 1
	elseif party.direction == 2 then
		y = party.y - 1
	elseif party.direction == 3 then
		x = party.x + 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end

	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:playFootstepSound()

end

function Game:strafeLeft()

	local x,y = party.x,party.y

	if party.direction == 0 then
		x = party.x - 1
	elseif party.direction == 1 then
		y = party.y - 1
	elseif party.direction == 2 then
		x = party.x + 1
	elseif party.direction == 3 then
		y = party.y + 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end

	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:playFootstepSound()

end

function Game:strafeRight()

	local x,y = party.x,party.y

	if party.direction == 0 then
		x = party.x + 1
	elseif party.direction == 1 then
		y = party.y + 1
	elseif party.direction == 2 then
		x = party.x - 1
	elseif party.direction == 3 then
		y = party.y - 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end

	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:playFootstepSound()

end

function Game:handleTileCollide(x, y)

	-- wall

	if level.data.walls and level.data.walls[x][y] then

		if level.data.walls[x][y].type == 1 then
			return true
		end

		if level.data.walls[x][y].type == 2 then
			assets:playSound("bushes")
			return false
		end
	
	end

	if level.data.boundarywalls and level.data.boundarywalls[x] and level.data.boundarywalls[x][y] then
		return true
	end
	
	-- door
	
	local door = level:getObject(level.data.doors, x,y)
	
	if door then
		if door.properties.type == 1 then
			assets:playSound("door-locked")
		elseif door.properties.type == 2 then
			self.isFading = true
			gameState = GameStates.LOADING_LEVEL
			fadeColor = {1,1,1}
			assets:playSound("city-gate")
			Game.currentDoor = door
			fadeMusicVolume.v = settings.musicVolume
			Timer.script(function(wait)
				Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
				end)
				Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
					Game.isFading = false
					assets:stopMusic(level.data.tileset)
					Game:loadArea(Game.currentDoor.properties.targetarea)
				end)
			end)
			
		end
		return true
	end
	
	-- enemies
	
	local enemy = level:getObject(level.data.enemies, x,y)
	
	if enemy and enemy.properties.state == 1 then
		return true
	end
	
	-- portal
	
	local portal = level:getObject(level.data.portals, x,y)
	
	if portal then
		-- walk through the portal
		return true
	end
	
	-- npc
	
	local npc = level:getObject(level.data.npcs, x,y)
	
	if npc then
		-- trigger the npc
		return true
	end
	
	-- chest
	
	local chest = level:getObject(level.data.chests, x,y)
	
	if chest then
		-- open the chest
		return true
	end
	
	-- well
	
	local well = level:getObject(level.data.wells, x,y)
	
	if well then
		-- drink from the well
		assets:playSound("drink-fountain")
		return true
	end	
	
	-- static prop
	
	local prop = level:getObject(level.data.staticprops, x,y)
	
	if prop then
	
		if prop.properties.name == "barricade" then

			assets:playSound("barricade-hurt")
			
			party.stats.health = party.stats.health - 10
		
			if party.stats.health <= 0 then
				assets:playSound("player-death")
				party:died()
			end			
			
			return true
		end
	
		return true
	end		
	
	return false

end

function Game:teleportTo(x, y, direction)

	party.x = x
	party.y = y
	party.direction = direction

	self:stepOnGround()

end

function Game:stepOnGround()

	-- Spinner

	local spinner = level:getObject(level.data.spinners, party.x, party.y)

	if spinner then
		party.direction = party.direction + 2
		if party.direction > 3 then
			party.direction = (party.direction - 4)
		end
		return
	end
	
	--[[
	if level.data.triggers[party.x] and level.data.triggers[party.x][party.y] and level.data.triggers[party.x][party.y].state == 1 then
		
		local trigger = level.data.triggers[party.x][party.y]
		
		trigger.state = 2
		globalvariables:add(trigger.id, "state", 2)

		if trigger.text ~= "" then
			messages:add(trigger.text)
		end
		
		if trigger.vars ~= "" then
			messages:add(trigger.vars)
		end		
		
		return
	end
	]]--

	
end

function Game:loadArea(id)

	if level:load(id, self.currentDoor) then

		if not atlases:load(level.data.tileset) then
			love.graphics.setCanvas(self.canvas)
			love.graphics.clear()
			love.graphics.setColor(1,1,1,1)
			love.graphics.setLineWidth(1)
			love.graphics.setLineStyle("rough")

			love.graphics.setColor(1,1,1,1)
			love.graphics.setFont(assets.fonts["main"]);	
			love.graphics.print("-- FATAL ERROR --",10,10)
			love.graphics.print("> Error loading atlases. Check console output.",10,40)
			love.graphics.print("Press any key to quit.",10,70)
			love.graphics.setCanvas()
			gameState = GameStates.FATAL_ERROR
			subState = SubStates.IDLE
			return
		end	
	
		level.loaded = true

		local map = level:generatePathMap()

		self.enemies = {}
			
		for key,value in pairs(level.data.enemies) do
			local e = level.data.enemies[key]
			local enemy = Enemy:new(e)
			enemy:setMap(map)
			table.insert(self.enemies, enemy)
		end

		gameState = GameStates.EXPLORING
		subState = SubStates.IDLE

		Timer.tween(1, fadeColor, {1,1,1}, 'in-out-quad', function()
			Game:stepOnGround()
			Game.footStepIndex = 1
			assets:playMusic(level.data.tileset)
		end)
		
	else
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		love.graphics.setColor(1,1,1,1)
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle("rough")

		love.graphics.setColor(1,1,1,1)
		love.graphics.setFont(assets.fonts["main"]);	
		love.graphics.print("-- FATAL ERROR --",10,10)
		love.graphics.print("> Error loading level: \""..id..".lua\"",10,40)
		love.graphics.print("Press any key to quit.",10,70)
		love.graphics.setCanvas()
		gameState = GameStates.FATAL_ERROR
		subState = SubStates.IDLE
	end

end

function Game:startGame()

	fadeColor = {1,1,1}
	self.isFading = true
	Timer.script(function(wait)
		Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
		end)
		Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
			gameState = GameStates.LOADING_LEVEL
			Game.isFading = false
			assets:stopMusic("mainmenu")
			Game:loadArea(startingArea)
		end)
	end)
			
end

function Game:jumpToMainmenu()


	Timer.clear()

	gameState = GameStates.MAIN_MENU

	fadeColor = {1,1,1}

	love.graphics.setColor(1,1,1,1)

	assets:stopMusic("buildup")
	assets:playMusic("mainmenu")

end


function buildUpStep2()

	gameState = GameStates.BUILDUP2

	Timer.script(function(wait)
		Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
		wait(4)
		Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', buildUpStep3)
	end)

end

function buildUpStep3()

	gameState = GameStates.BUILDUP3

	Timer.script(function(wait)
		Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
		wait(4)
		Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', buildUpStep4)
	end)

end

function buildUpStep4()

	gameState = GameStates.BUILDUP4

	Timer.script(function(wait)
		Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
		wait(5.5)
		Game.isFading = false
		Game:jumpToMainmenu()
	end)

end

---------------------------------------------------------------------------------------------------------------------------

return Game