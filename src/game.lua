local Messages = require "messages"
local Renderer = require "renderer"
local Assets = require "assets"
local Party = require "party"
local Level = require "level"
local Atlases = require "atlases"
local Enemy = require "enemy"

local GlobalVariables = require "globalvariables"
local ItemTemplates = require "itemtemplates"

local GameStates = {
	INIT = 0,
	EXPLORING = 1,
	LOADING_LEVEL = 2,
	COMBAT = 3,
	RESTING = 4,
	MAP = 5,
	INVENTORY = 6,
	CHEST = 7,
	NPC = 8,
	TREASURE = 9,
	SPELLBOOK = 10,
	FATAL_ERROR = 11
}

local SubStates = {
	IDLE = 0,
	INSPECT_DOOR = 1,
	PUSH_BUTTON = 2,
	SELECT_SPELLCASTER = 3,
	SELECT_PLAYER_SPELL_TARGET = 4
}

assets = Assets:new()
renderer = Renderer:new()
level = Level:new()
atlases = Atlases:new()
party = Party:new()
messages = Messages:new()
globalvariables = GlobalVariables:new()

local Game = class('Game')

function Game:initialize()

	math.randomseed(os.time())

	self.gameState = GameStates.INIT
	self.subState = SubStates.IDLE
	self.footStepIndex = 1
	love.graphics.setDefaultFilter( "nearest", "nearest", 0)
	
end

function Game:init()

	love.mouse.setVisible(false)
	
	self.isFullscreen = love.window.fullscreen
	self.canvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)

	assets:load()
	
	renderer:init(self)
	
	self.gameState = GameStates.LOADING_LEVEL

	self:loadArea("city")
	self.gameState = GameStates.EXPLORING
	self.subState = SubStates.IDLE

end

function Game:update(dt)

	if self.gameState ~= GameStates.INIT then
	
		for key,value in pairs(self.enemies) do
			self.enemies[key]:update(dt)
		end
		
		party:update(dt)
		renderer:update(dt)
		
	end
	
end

function Game:handleInput(key)

	local key = string.lower(key)

	if self.gameState == GameStates.INIT then
		return
	end

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

	if self.gameState == GameStates.FATAL_ERROR then

		love.event.quit()

		return
	end

	-- EXPLORING

	if self.gameState == GameStates.EXPLORING then

		if self.subState == SubStates.IDLE then

			if key == 'escape' then
				love.event.quit()
			end

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

			if key == 'm' then
				renderer.showMinimap = not renderer.showMinimap
				return
			end	
			
			if key == '1' then
				party:attack(1, self.enemies)
				return
			end				

			if key == '2' then
				party:attack(2, self.enemies)
				return
			end				
			
		end

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
			assets:playSound("city-gate")
			self.gameState = GameStates.LOADING_LEVEL
			self.currentDoor = door
			renderer:fadeOut()
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
	
	-- Enemy

	--[[
	if level.data.encounters[party.x] and level.data.encounters[party.x][party.y] and level.data.encounters[party.x][party.y].state == 1 and level.data.encounters[party.x][party.y].visible == 0 then
		local encounter = level.data.encounters[party.x][party.y]
		party.oldX = party.x
		party.oldY = party.y
		screens.combatscreen:show(encounter, 1)
		self.gameState = GameStates.COMBAT
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
			self.gameState = GameStates.FATAL_ERROR
			self.subState = SubStates.IDLE
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

		self:stepOnGround()
		self.footStepIndex = 1
		assets:playMusic(level.data.tileset)

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
		self.gameState = GameStates.FATAL_ERROR
		self.subState = SubStates.IDLE
	end

end

--[[-----------------------------------------------------------------------------------------------------------------------

	Callback events
	
-----------------------------------------------------------------------------------------------------------------------]]--

function Game:onBeforeLevelExit()

	assets:stopMusic(level.data.tileset)
	self:loadArea(self.currentDoor.properties.targetarea)

	renderer:fadeIn()

end

function Game:onAfterLevelExit()

	self.gameState = GameStates.EXPLORING
	self.subState = SubStates.IDLE

end

---------------------------------------------------------------------------------------------------------------------------

return Game