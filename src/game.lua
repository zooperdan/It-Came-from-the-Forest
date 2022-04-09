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
	
end

function Game:init()

	love.mouse.setGrabbed(true)
	love.mouse.setVisible(false)
	
	self.isFullscreen = love.window.fullscreen
	self.canvas = love.graphics.newCanvas(screen.width, screen.height)

	assets:load()
	
	renderer:init(self)
	
	if settings.quickstart then
		gameState = GameStates.LOADING_LEVEL
		assets:stopMusic("mainmenu")
		Game:loadArea(settings.startingArea)
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
	
		if gameState == GameStates.EXPLORING then
			
			if subState == SubStates.IDLE then
				
				if self:checkIfClickedOnFacingObject(x, y) then
					return
				end
				
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

	self:tick()

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

	self:tick()

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

	self:tick()

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

	self:tick()

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
	
	-- enemies
	
	local enemy = level:getObject(level.data.enemies, x,y)
	
	if enemy and enemy.properties.state == 1 then
		return true
	end
	
	-- portal
	
	if level:getObject(level.data.portals, x,y) then
		return true
	end
	
	-- npc
	
	local npc = level:getObject(level.data.npcs, x,y)
	
	if npc and npc.properties.visible == 1 then
		return true
	end
	
	-- chest
	
	if level:getObject(level.data.chests, x,y) then
		return true
	end
	
	-- well
	
	local well = level:getObject(level.data.wells, x,y)
	
	if level:getObject(level.data.wells, x,y) then
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
	
	-- Trigger
	
	local trigger = level:getObject(level.data.triggers, party.x, party.y)

	if trigger and trigger.properties.state == 1 then
		renderer:showPopup(trigger.properties.text)
		trigger.properties.state = 2
		globalvariables:add(trigger.properties.id, "state", trigger.properties.state)
		if trigger.vars ~= "" then
			--messages:add(trigger.vars)
		end		
		return
	end	
	
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

		-- update objects that have a cooldown
		
		for key,value in pairs(level.data.wells) do
			
			local well = level.data.wells[key]

			well.properties.counter = well.properties.counter - party.ticksElapsed
			
			if well.properties.counter < 0 then
				well.properties.counter = 0
			end

		end	
	
		party.ticksElapsed = 0

		-- update state

		gameState = GameStates.EXPLORING
		subState = SubStates.IDLE

		-- fade in

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

	subState = SubStates.LOADING_LEVEL
	fadeColor = {1,1,1}
	Timer.script(function(wait)
		Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
		end)
		Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
			gameState = GameStates.LOADING_LEVEL
			assets:stopMusic("mainmenu")
			Game:loadArea(settings.startingArea)
		end)
	end)
			
end

function Game:checkIfClickedOnFacingObject(x, y)

	-- npc

	local door = level:getFacingObject(level.data.doors, x, y)
	
	if door and intersectBox(x, y, world_hitboxes["door"]) then
		if door.properties.type == 1 then
			
			if door.properties.vendor ~= "" then
			
				renderer:showVendor(door.properties.vendor)

			else
				assets:playSound("door-locked", false)
				renderer:showPopup("There doesn't seem to be anyone home, or they're just too scared to open the door.", false)
			end

		elseif door.properties.type == 2 then
			if door.properties.state == 1 then
				if door.properties.keyid and door.properties.keyid ~= "" then
					if party:consumeItem(door.properties.keyid) then
						renderer:showPopup("You use a key to unlock the door.")
						door.properties.keyid = ""
						globalvariables:add(door.properties.id, "keyid", door.properties.keyid)
						assets:playSound("chest-open")
						return true
					else
						renderer:showPopup("You don't have the key that unlocks this door.")
					end
				else
					gameState = GameStates.LOADING_LEVEL
					fadeColor = {1,1,1}
					assets:playSound("city-gate")
					Game.currentDoor = door
					fadeMusicVolume.v = settings.musicVolume
					Timer.script(function(wait)
						Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
						end)
						Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
							assets:stopMusic(level.data.tileset)
							Game:loadArea(Game.currentDoor.properties.targetarea)
						end)
					end)				
				end
			else
				renderer:showPopup("The door is blocked by some unknown mechanism.")
			end
		end
		return true
	end

	-- npc
	
	local npc = level:getFacingObject(level.data.npcs, x, y)

	if npc and intersectBox(x, y, world_hitboxes["npc"]) then
		if npc.properties.state == 2 then
			npc.properties.state = 3
			globalvariables:add(npc.properties.id, "state", npc.properties.state)
		else
			if checkCriterias(npc.properties.criterias) then
				npc.properties.state = 2
				globalvariables:add(npc.properties.id, "state", npc.properties.state)
				level:applyVars(npc.properties.vars)
			end		
		end
		renderer:showNPC(npc)
		return true
	end

	-- portal
	
	local portal = level:getFacingObject(level.data.portals, x, y)
	
	if portal and intersectBox(x, y, world_hitboxes["portal"]) then
		if portal.properties.state == 1 then
			party.y = portal.properties.targety+1
			party.x = portal.properties.targetx+1
			party.direction = portal.properties.targetdir
			renderer:flipGround()
			self:stepOnGround()
			self:playFootstepSound()
			self:tick()
		else
			renderer:showPopup("The portal seems to be inactive.")
		end
		return true
	end
	
	-- chest
	
	local chest = level:getFacingObject(level.data.chests, x,y)
	
	if chest and intersectBox(x, y, world_hitboxes["chest"]) then
		-- open the chest
		if chest.properties.state == 1 then
			if chest.properties.keyid and chest.properties.keyid ~= "" then
				if party:consumeItem(chest.properties.keyid) then
					chest.properties.keyid = ""
					globalvariables:add(chest.properties.id, "keyid", chest.properties.keyid)
					assets:playSound("unlock")
					renderer:showPopup("You use a key to unlock the chest.", false)
					return true
				else
					renderer:showPopup("You don't have the key that unlocks this chest.")
				end
			else
				chest.properties.state = 2
				globalvariables:add(chest.properties.id, "state", chest.properties.state)
				assets:playSound("chest-open")
			end
		
		else
			chest.properties.state = 1
			globalvariables:add(chest.properties.id, "state", chest.properties.state)
			assets:playSound("chest-close")
		end
		return true
	end
	
	-- well
	
	local well = level:getFacingObject(level.data.wells, x,y)
	
	if well and intersectBox(x, y, world_hitboxes["well"]) then
		-- drink from the well
		if well.properties.counter > 0 then
			renderer:showPopup("Drinking from the well has no effect. Maybe try again later?")
		else
			if party.stats.health < party.stats.health_max then
				party.stats.health = party.stats.health_max
				assets:playSound("drink-fountain")
				well.properties.counter = well.properties.counter_max
				globalvariables:add(well.properties.id, "counter", well.properties.counter)
			else
				renderer:showPopup("You already have maximum health.")
			end
		end
		return true
	end	
	
	-- static prop
	
	local prop = level:getFacingObject(level.data.staticprops, x,y)
	
	if prop and intersectBox(x, y, world_hitboxes["prop"]) then
	
		if prop.properties.name == "notice-board" then
			renderer:showPopup("Such handsome guys!")
			return true
		end
	
	end		
	
	-- button
	
	local button = level:getFacingObject(level.data.buttons, x,y)
	
	if button and intersectBox(x, y, world_hitboxes["button"]) then
		if button.properties.state == 1 then
			button.properties.state = 2
			globalvariables:add(button.properties.id, "state", button.properties.state)
			level:applyVars(button.properties.vars)
		end
		return true
	end		
	
	return false
	
end

function Game:jumpToMainmenu()


	Timer.clear()

	gameState = GameStates.MAIN_MENU

	fadeColor = {1,1,1}

	love.graphics.setColor(1,1,1,1)

	assets:stopMusic("buildup")
	assets:playMusic("mainmenu")

end

function Game:tick()

	-- count down on all the wells in this area
	
	for key,value in pairs(level.data.wells) do
		
		local well = level.data.wells[key]

		well.properties.counter = well.properties.counter - 1
		
		if well.properties.counter < 0 then
			well.properties.counter = 0
		end

	end	

	party.ticksElapsed = party.ticksElapsed + 1

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
		Game:jumpToMainmenu()
	end)

end

---------------------------------------------------------------------------------------------------------------------------

return Game