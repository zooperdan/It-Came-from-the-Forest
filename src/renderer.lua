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
	self.offsetx = 11
	self.offsety = 11
	
	self.fadeSpeed = 3.0
	self.fadeCounter = 0
	self.dofadeIn = true	
	self.dofadeOut = false	

end

function Renderer:update(dt)

	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(assets.fonts["main"]);
	
	self:drawViewport()
	self:drawUI()
	
	love.graphics.setCanvas()

	if self.dofadeIn then
		love.graphics.setColor(1,1,1,self.fadeCounter)
		self.fadeCounter = self.fadeCounter + (dt * self.fadeSpeed)
		if self.fadeCounter >= 1 then
			self.dofadeIn = false
			self.fadeCounter = 0
			self.caller:onAfterLevelExit()
		end
	end	
	
	if self.dofadeOut then
		love.graphics.setColor(1,1,1,self.fadeCounter)
		self.fadeCounter = self.fadeCounter - (dt * self.fadeSpeed)
		if self.fadeCounter <= 0 then
			self.dofadeOut = false
			self.fadeCounter = 0
			self.caller:onBeforeLevelExit()
		end
	end	
	
end

function Renderer:fadeIn()

	if self.dofadeOut then
		self.dofadeOut = false
	else
		self.fadeCounter = 0
	end

	self.dofadeIn = true

end

function Renderer:fadeOut()

	if self.dofadeIn then
		self.dofadeIn = false
	else
		self.fadeCounter = 1
	end

	self.dofadeOut = true

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

function Renderer:drawUI()

	self:drawText(10, 10, direction_names[party.direction])
	self:drawText(-10, 10, party.x .. "/" .. party.y, "right")
	self:drawText(10, 340, tostring(love.timer.getFPS()))
	
	self:drawText(10, 315, math.floor(collectgarbage('count')) .. " Kb")
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
				self:drawObject("enemies", self:getObjectDirectionID("ant", enemy.properties.direction), x, z)
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
