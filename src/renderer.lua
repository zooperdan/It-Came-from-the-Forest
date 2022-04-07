local Renderer = class('Renderer')

local direction_names = {[0] = "North", [1] = "East", [2] = "South", [3] = "West"}

function Renderer:initialize()
	
end

function Renderer:init(caller)
	
	self.caller = caller
	self.canvas = caller.canvas
	self.dungeonDepth = 6
	self.dungeonWidth = 4
	self.backgroundIndex = 1
	self.skyIndex = 1
	self.showMinimap = false
	
end

function Renderer:update(dt)

	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(assets.fonts["main"]);
	love.graphics.setLineStyle("rough")
	love.graphics.setShader(highlightshader)
	
	if gameState == GameStates.EXPLORING then
	
		self:drawViewport()

		-- Enemy in front of player?

		local enemy = level:getFacingEnemy()
		
		if enemy and enemy.properties.state == 1 then
			self:drawEnemyStats(enemy)
		end

		if self.showMinimap then
			self:drawMinimap()
		end

		self:drawUI()
	
	end

	if gameState == GameStates.BUILDUP1 then love.graphics.draw(assets.images["buildup-screen-1"], 0, 0) end
	if gameState == GameStates.BUILDUP2 then love.graphics.draw(assets.images["buildup-screen-2"], 0, 0) end
	if gameState == GameStates.BUILDUP3 then love.graphics.draw(assets.images["buildup-screen-3"], 0, 0) end
	if gameState == GameStates.BUILDUP4 then love.graphics.draw(assets.images["buildup-screen-4"], 0, 0) end
	
	if gameState == GameStates.MAIN_MENU then
		love.graphics.draw(assets.images["opening-image"], 0, 0)	
	end
	
	if gameState == GameStates.CREDITS then
		love.graphics.draw(assets.images["credits"], 0, 0)	
	end	
	
	if gameState == GameStates.EXPLORING or gameState == GameStates.MAIN_MENU or gameState == GameStates.CREDITS then
		self:drawPointer()	
	end
	
	love.graphics.setCanvas()

end

function Renderer:flipGround()

	self.backgroundIndex = self.backgroundIndex + 1
	if self.backgroundIndex > 2 then
		self.backgroundIndex = 1
	end
	
end

function Renderer:flipSky()

	self.skyIndex = self.skyIndex + 1
	if self.skyIndex > 2 then
		self.skyIndex = 1
	end
	
end

function Renderer:getPlayerDirectionVectorOffsets(x, z)

    if party.direction == 0 then
        return { x = party.x + x, y = party.y + z };
	elseif party.direction == 1 then
		return { x = party.x - z, y = party.y + x };
	elseif party.direction == 2 then
		return { x = party.x - x, y = party.y - z };
	elseif party.direction == 3 then
		return { x = party.x + z, y = party.y - x };
	end
	

end

function Renderer:getObjectDirectionID(prefix, direction)

	local result = nil
	
	if direction == -1 then
		return prefix
	end
	
	
	if direction == 0 then
		if party.direction == 2 then
			result = prefix.."-1"
		end
		if party.direction == 0 then
			result = prefix.."-2"
		end
		if party.direction == 1 then
			result = prefix.."-4"
		end			
		if party.direction == 3 then
			result = prefix.."-3"
		end	
	elseif direction == 1 then
		if party.direction == 2 then
			result = prefix.."-4"
		end
		if party.direction == 0 then
			result = prefix.."-3"
		end
		if party.direction == 1 then
			result = prefix.."-2"
		end			
		if party.direction == 3 then
			result = prefix.."-1"
		end					
	elseif direction == 2 then
		if party.direction == 2 then
			result = prefix.."-2"
		end
		if party.direction == 0 then
			result = prefix.."-1"
		end
		if party.direction == 1 then
			result = prefix.."-3"
		end			
		if party.direction == 3 then
			result = prefix.."-4"
		end	
	elseif direction == 3 then
		if party.direction == 2 then
			result = prefix.."-3"
		end
		if party.direction == 0 then
			result = prefix.."-4"
		end
		if party.direction == 1 then
			result = prefix.."-1"
		end			
		if party.direction == 3 then
			result = prefix.."-2"
		end	
	end
		
	return result
		
end



function Renderer:getTile(atlasId, layerId, tileType, x, z)

	if not atlases.jsondata[atlasId].layer[layerId] then
		return nil
	end

	local layer = atlases.jsondata[atlasId].layer[layerId]
	
	if not layer then return false end
	
	for i = 1, #layer.tiles do
		local tile = layer.tiles[i]
		if tile.type == tileType and tile.tile.x == x and tile.tile.y == z then
			return tile
		end
	end

	return nil
	
end

function Renderer:drawText(x, y, text, align)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x+2, y+2, 640, align)
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(text, x, y, 640, align)
	
end

function Renderer:drawPointer()

	local x, y = love.mouse.getPosition()

	if x > screen.width then
		love.mouse.setPosition(screen.width,love.mouse.getY())
	end
	
	if y > screen.height then
		love.mouse.setPosition(love.mouse.getX(), screen.height)
	end	
	
	love.graphics.draw(assets.images["pointer"], x, y)

end

function Renderer:drawMinimap()

	self:drawText(10, 340, tostring(love.timer.getFPS()))

	local cellsize = 6
	local offsetx = screen.width/2 - (level.data.mapSize * cellsize)/2
	local offsety = 75--screen.height/2 - (level.data.mapSize * cellsize)/2

	local amx = screen.width/2 - assets.images["automapper-background"]:getWidth()/2
	love.graphics.draw(assets.images["automapper-background"], amx, 40)
	
	for y = 1, level.data.mapSize do
		for x = 1, level.data.mapSize do
		
			local dx = offsetx + (x * cellsize)
			local dy = offsety + (y * cellsize)
		
			love.graphics.setColor(0,0,0,.5)
			love.graphics.rectangle("fill", dx, dy, cellsize, cellsize)
		
			if level.data.walls[x] and level.data.walls[x][y] then
				love.graphics.setColor(1,1,1,1)
				love.graphics.rectangle("fill", dx, dy, cellsize, cellsize)
			end

			if level.data.boundarywalls[x] and level.data.boundarywalls[x][y] then
				love.graphics.setColor(1,1,1,1)
				love.graphics.rectangle("fill", dx, dy, cellsize, cellsize)
			end
		
		end
	end

	-- doors

	for key,value in pairs(level.data.doors) do
		local door = level.data.doors[key]
		local dx = offsetx + (door.x * cellsize)
		local dy = offsety + (door.y * cellsize)
		love.graphics.setColor(1,0.5,0,1)
		love.graphics.rectangle("fill", dx, dy, cellsize, cellsize)
	end
	
	-- wells

	for key,value in pairs(level.data.wells) do
		local well = level.data.wells[key]
		local dx = offsetx + (well.x * cellsize)
		local dy = offsety + (well.y * cellsize)
		love.graphics.setColor(0,0.5,1,1)
		love.graphics.rectangle("fill", dx, dy, cellsize, cellsize)
	end
	
	-- enemies

	for key,value in pairs(level.data.enemies) do
		local enemy = level.data.enemies[key]
		if enemy.properties.state == 1 then
			local dx = offsetx + (enemy.x * cellsize)
			local dy = offsety + (enemy.y * cellsize)
			love.graphics.setColor(1,0,0,1)
			love.graphics.rectangle("fill", dx, dy, cellsize, cellsize)
		end
	end
		
	-- player
	
	local dx = offsetx + (party.x * cellsize)
	local dy = offsety + (party.y * cellsize)
	love.graphics.setColor(0,1,0,1)
	love.graphics.rectangle("fill", dx, dy, cellsize, cellsize)
	

	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawUI()

	--[[
	self:drawText(10, 10, direction_names[party.direction])
	self:drawText(-10, 10, party.x .. "/" .. party.y, "right")

	if party:hasCooldown(1) then
		love.graphics.setColor(1,0,0,1)
		love.graphics.rectangle("fill", 5, 40, 5, 5)
	else
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("fill", 5, 40, 5, 5)
	end

	if party:hasCooldown(2) then
		love.graphics.setColor(1,0,0,1)
		love.graphics.rectangle("fill", 15, 40, 5, 5)
	else
		love.graphics.setColor(1,1,1,1)
		love.graphics.rectangle("fill", 15, 40, 5, 5)
	end
	--]]
	
	love.graphics.setColor(1,1,1,1)

	love.graphics.draw(assets.images["test"], 0,0)

end

function Renderer:drawEnemyStats(enemy)

	self:drawText(0, 10+50, enemy.properties.name, "center")
	
	local x = math.floor(screen.width/2 - assets.images["enemy-hit-bar-1"]:getWidth()/2)
	local y = 30+50
	
	love.graphics.draw(assets.images["enemy-hit-bar-1"], x, y)

	if enemy.properties.health > 0 then

		local maxbarsize = 143

		local f = enemy.properties.health/enemy.properties.health_max
		local barsize = maxbarsize * f
		local quad = nil

		local offs = 3

		-- bar body
		quad = love.graphics.newQuad(1, 0, 1, 5, assets.images["enemy-hit-bar-2"]:getWidth(), assets.images["enemy-hit-bar-2"]:getHeight())
		love.graphics.draw(assets.images["enemy-hit-bar-2"], quad, x + offs, y + offs, 0, barsize, 1)

		-- left edge
		
		quad = love.graphics.newQuad(0, 0, 1, 5, assets.images["enemy-hit-bar-2"]:getWidth(), assets.images["enemy-hit-bar-2"]:getHeight())
		love.graphics.draw(assets.images["enemy-hit-bar-2"], quad, x + offs, y + offs)

		-- right edge
		
		quad = love.graphics.newQuad(2, 2, 1, 5, assets.images["enemy-hit-bar-2"]:getWidth(), assets.images["enemy-hit-bar-2"]:getHeight())
		love.graphics.draw(assets.images["enemy-hit-bar-2"], quad, (x + offs) + (barsize-1), y + offs)

	end

end

function Renderer:drawObject(atlasId, layerId, x, z)

	local bothsides = atlases.jsondata[atlasId].layer[layerId] and atlases.jsondata[atlasId].layer[layerId].mode == 2
	
	local xx = bothsides and x - (x * 2) or 0
	local tile = self:getTile(atlasId, layerId, "object", xx, z);

	if tile then

		local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())

		if bothsides then
			love.graphics.draw(atlases.images[atlasId], quad, tile.screen.x, tile.screen.y)
		else
			local tx = tile.screen.x + (x * tile.coords.w)
			love.graphics.draw(atlases.images[atlasId], quad, tx, tile.screen.y)
		end

	end
	
end

function Renderer:drawGround()
	

	local atlasId = level.data.tileset .. "-environment"

    for z = -self.dungeonDepth, 0 do
		
		for x = -self.dungeonWidth, self.dungeonWidth do

			local p = self:getPlayerDirectionVectorOffsets(x, z);

			if p.x >= 1 and p.y >= 1 and p.x <= level.data.mapSize and p.y <= level.data.mapSize then
			
				local layerId = self.backgroundIndex == 1 and level.data.tileset.."-ground-1" or level.data.tileset.."-ground-2"
				local bothsides = atlases.jsondata[atlasId].layer[layerId] and atlases.jsondata[atlasId].layer[layerId].mode == 2
				local xx = bothsides and x - (x * 2) or 0
				local tile = self:getTile(atlasId, layerId, "ground", xx, z);
				
				if tile then

					local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())

					if bothsides then
						love.graphics.draw(atlases.images[atlasId], quad, tile.screen.x, tile.screen.y)
					else
						local tx = tile.screen.x + (x * tile.coords.w)
						love.graphics.draw(atlases.images[atlasId], quad, tx, tile.screen.y)
					end

				end		
				
			end
			
		end		

	end
	
end

function Renderer:drawSky()

	if self.skyIndex == 1 then
		love.graphics.draw(assets.images["sky"], 0, 0)
	else
		love.graphics.draw(assets.images["sky"], 640, 0, 0, -1, 1)
	end
	
end

function Renderer:drawSquare(x, z)

    local p = self:getPlayerDirectionVectorOffsets(x, z);

    if p.x >= 1 and p.y >= 1 and p.x <= level.data.mapSize and p.y <= level.data.mapSize then

		if level.data.walls[p.x] and level.data.walls[p.x][p.y] then
			local wall = level.data.walls[p.x][p.y]
			if wall.type ~= 3 then
				self:drawObject(level.data.tileset .. "-environment", "walls", x, z)
			end
		end
		
		if level.data.boundarywalls[p.x] and level.data.boundarywalls[p.x][p.y] then
			local wall = level.data.boundarywalls[p.x][p.y]
			if wall.type == 3 then
				self:drawObject(level.data.tileset .. "-environment", "boundarywalls", x, z)
			end
		end
		
		for key,value in pairs(level.data.staticprops) do
			local prop = level.data.staticprops[key]
			if prop.x == p.x and prop.y == p.y then
				self:drawObject(prop.properties.atlasid, self:getObjectDirectionID(prop.properties.name, prop.properties.direction), x, z)
			end
		end
		
		for key,value in pairs(level.data.enemies) do
			local enemy = level.data.enemies[key]
			if enemy.x == p.x and enemy.y == p.y then
				if enemy.highlight and enemy.highlight == 1 then
					highlightshader:send("WhiteFactor", 1)
				end
				if enemy.properties.state == 1 then
					if enemy.properties.attacking == 1 then
						self:drawObject("enemies", self:getObjectDirectionID("ant-attack", enemy.properties.direction), x, z)
					else 
						self:drawObject("enemies", self:getObjectDirectionID("ant", enemy.properties.direction), x, z)
					end
				elseif enemy.properties.state == 3 then
					self:drawObject("enemies", self:getObjectDirectionID("ant-dead", enemy.properties.direction), x, z)
				end			
				highlightshader:send("WhiteFactor", 0)
			end
		end
		
		for key,value in pairs(level.data.npcs) do
			local npc = level.data.npcs[key]
			if npc.x == p.x and npc.y == p.y then
				self:drawObject("npc", npc.properties.imageid, x, z)			
			end
		end		

		for key,value in pairs(level.data.chests) do
			local chest = level.data.chests[key]
			if chest.x == p.x and chest.y == p.y then
				self:drawObject("common-props", "crate", x, z)			
			end
		end

		for key,value in pairs(level.data.wells) do
			local well = level.data.wells[key]
			if well.x == p.x and well.y == p.y then
				self:drawObject("common-props", self:getObjectDirectionID("well", well.properties.direction), x, z)			
			end
		end
		
		for key,value in pairs(level.data.doors) do
			local door = level.data.doors[key]
			if door.x == p.x and door.y == p.y then
				if door.properties.type == 1 then
					self:drawObject(level.data.tileset .. "-environment", "door", x, z)			
				elseif door.properties.type == 2 then
					local objId = self:getObjectDirectionID("gate", door.properties.direction)
					self:drawObject(level.data.tileset .. "-environment", objId and objId or "gate", x, z)			
				end
			end
		end
		
		for key,value in pairs(level.data.portals) do
			local portal = level.data.portals[key]
			if portal.x == p.x and portal.y == p.y then
				self:drawObject(level.data.tileset .. "-props", self:getObjectDirectionID("portal", portal.properties.direction), x, z)			
			end
		end		
		
	end

end

function Renderer:drawViewport()

	if not level.loaded then 
		return
	end	

	self:drawSky()
	self:drawGround()
	
    for z = -self.dungeonDepth, 0 do
		
		for x = -self.dungeonWidth, -1 do
			self:drawSquare(x, z)
		end		

		for x = self.dungeonWidth, 1, -1 do
			self:drawSquare(x, z)
		end		
		
		self:drawSquare(0, z)
	
	end

end

return Renderer
