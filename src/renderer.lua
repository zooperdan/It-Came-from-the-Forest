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
	self.doShowInventory = false
	self.currentHoverItem = nil
	self.doShowSpellList = false
	
	self.buttons = {}
	
	local button = Button:new()
	button.id = "close"
	button.x = settings.inventoryX+380
	button.y = settings.inventoryY+216
	button.width = 15
	button.height = 16
	button.normal = "button-close-1"
	button.over = "button-close-2"
	button.trigger = self.onCloseButtonClick
	
	self.buttons[button.id] = button
	
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

		if self.doShowInventory then
			self:drawInventory()
			self:showPlayerStats()
		end
		
		if self.doShowSpellList then
			self:drawSpellList()
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
	
	if self.currentHoverItem then
		self:showItemHoverStats(self.currentHoverItem)
	end
	
	love.graphics.setCanvas()

end

function Renderer:handleMousePressed(x, y, button)
	
	if button == 1 then

		if self.doShowInventory then
			self:clickOnInventory(x, y)
			return
		end
	
		if self.doShowSpellList then
			self:onSpellSelect(x, y)
			return
		end
	
	end
	
end

function Renderer:handleInput(key)

	if inventoryDragSource.item ~= nil then
		return
	end
	
	if key == 'i' then
		self:showInventory(false)
		return
	end

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
	love.graphics.printf(text, x+1, y+1, 640, align)
	love.graphics.setColor(1,1,1,1)
	love.graphics.printf(text, x, y, 640, align)
	
end

function Renderer:drawWrappedText(x, y, text, wrapAt, color)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x+1, y+1, wrapAt, "left")
	love.graphics.setColor(color)
	love.graphics.printf(text, x, y, wrapAt, "left")
	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawPointer()

	local x, y = love.mouse.getPosition()

	if x > screen.width then
		love.mouse.setPosition(screen.width,love.mouse.getY())
	end
	
	if y > screen.height then
		love.mouse.setPosition(love.mouse.getX(), screen.height)
	end	
	
	local x, y = love.mouse.getPosition()
	
	self:drawText(20, 20, tostring(x) .. "/" .. tostring(y))
	
	if inventoryDragSource.item and assets.itemicons[inventoryDragSource.item.id] then
		love.graphics.draw(assets.itemicons[inventoryDragSource.item.id], x-16, y-16)
	else
		love.graphics.draw(assets.images["pointer"], x, y)
	end
	
end

function Renderer:drawSpellList()

	love.graphics.setColor(1,1,1,1)

	self:drawText(20, 200, "SELECT SPELL")

end

function Renderer:drawInventory()

	local mx, my = love.mouse.getPosition()

	love.graphics.setColor(1,1,1,1)

	love.graphics.draw(assets.images["inventory-ui"],  settings.inventoryX, settings.inventoryY)


	self.buttons["close"]:isOver(mx, my)
	
	love.graphics.draw(self.buttons["close"]:getImage(),  settings.inventoryX + 380, settings.inventoryY + 216)

	local slotsize = 33
	local hovercell = nil
	local showingItemStats = false

	self.currentHoverItem = nil

	-- equipment slots
	
	for i = 1, #party.equipmentslots do
	
		local x = settings.inventoryX + party.equipmentslots[i].x
		local y = settings.inventoryY + party.equipmentslots[i].y
		
		-- draw slot highlight
		
		if intersect(mx, my, x, y, slotsize, slotsize) then
			love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
			if party.equipmentslots[i].id ~= "" then
				self.currentHoverItem = itemtemplates:get(party.equipmentslots[i].id)
			end
			hovercell = {index = i}
		end
		
		-- draw slot highlight for matching slot type
		
		if inventoryDragSource.item then
		
			local item = itemtemplates:get(inventoryDragSource.item.id)
			
			if party.equipmentslots[i].type == item.slot then
				love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
			end
		
		end
		
		-- draw item icons
		
		if party.equipmentslots[i].id ~= "" then
		
			local item = itemtemplates:get(party.equipmentslots[i].id)

			if item and assets.itemicons[item.id] then
				love.graphics.draw(assets.itemicons[item.id], x+1, y+1)
			end
			
		end
		
	end	

	if hovercell and not inventoryDragSource.item and party.equipmentslots[hovercell.index].id ~= "" then
		showingItemStats = true
		local item = itemtemplates:get(party.equipmentslots[hovercell.index].id)
		--self:showItemHoverStats(item)
	end
	
	-- inventory slots

	hovercell = nil

	for row = 1, 5 do
		for col = 1, 8 do
		
			local x = settings.inventorySlotsStartX + (col-1) * slotsize
			local y = settings.inventorySlotsStartY + (row-1) * slotsize
			
			-- draw slot highlight
			
			if intersect(mx, my, x, y, slotsize, slotsize) then
				love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
				if party.inventory[row][col] ~= "" then
					self.currentHoverItem = itemtemplates:get(party.inventory[row][col])
				end
				hovercell = {row = row, col = col}
			end
			
			-- draw item icons
			
			if party.inventory[row][col] ~= "" then
			
				local item = itemtemplates:get(party.inventory[row][col])
	
				if item and assets.itemicons[item.id] then
					love.graphics.draw(assets.itemicons[item.id], x+1, y+1)
				end
				
			end
			
		end
	end
	
	if hovercell and not inventoryDragSource.item and party.inventory[hovercell.row][hovercell.col] ~= "" then
		showingItemStats = true
		local item = itemtemplates:get(party.inventory[hovercell.row][hovercell.col])
		--self:showItemHoverStats(item)
	end
	
end

function Renderer:clickOnInventory(mx, my)

	if not inventoryDragSource.item then
		if self.buttons["close"]:isOver(mx, my) then
			self.buttons["close"].trigger()
		end
	end

	local slotsize = 33

	-- equipment slots
	
	for i = 1, #party.equipmentslots do
	
		local x = settings.inventoryX + party.equipmentslots[i].x
		local y = settings.inventoryY + party.equipmentslots[i].y
		
		if intersect(mx, my, x, y, slotsize, slotsize) then
	
			if inventoryDragSource.item then
	
				if party.equipmentslots[i].type == inventoryDragSource.item.slot then
	
					if party.equipmentslots[i].id == "" then
		
						party.equipmentslots[i].id = inventoryDragSource.item.id
			
						inventoryDragSource = {}

					else
					
						local item = itemtemplates:get(party.equipmentslots[i].id)
						
						party.equipmentslots[i].id = inventoryDragSource.item.id

						inventoryDragSource = {
							source = "equipment",
							item = item,
							src_row = row,
							src_col = col,
						}

					end

				end
				
			else
			
				if party.equipmentslots[i].id ~= "" then

					local item = itemtemplates:get(party.equipmentslots[i].id)
					
					inventoryDragSource = {
						source = "equipment",
						item = item,
						src_row = row,
						src_col = col,
					}
					
					party.equipmentslots[i].id = ""
					
				else 
					inventoryDragSource = {}
				end				
			
			end
	
		end
		
	end

	-- inventory slots

	if intersect(mx, my, settings.inventorySlotsStartX, settings.inventorySlotsStartY, 295, 184) then

		local col = math.floor((mx - settings.inventorySlotsStartX) / slotsize)+1
		local row = math.floor((my - settings.inventorySlotsStartY) / slotsize)+1
		
		col = math.clamp(col, 1, 8)
		row = math.clamp(row, 1, 5)

		if inventoryDragSource.item then
		
			if party.inventory[row][col] == "" then

				party.inventory[row][col] = inventoryDragSource.item.id
			
				inventoryDragSource = {}

			else

				local item = itemtemplates:get(party.inventory[row][col])
				
				party.inventory[row][col] = inventoryDragSource.item.id

				inventoryDragSource = {
					source = "inventory",
					item = item,
					src_row = row,
					src_col = col,
				}				

			end
		
		else

			if party.inventory[row][col] ~= "" then

				local item = itemtemplates:get(party.inventory[row][col])
				
				inventoryDragSource = {
					source = "inventory",
					item = item,
					src_row = row,
					src_col = col,
				}
				
				party.inventory[row][col] = ""
				
			else 
				inventoryDragSource = {}
			end
			
		end
	
	end
	
	party:updateStats()
	
end

function Renderer:onSpellSelect(mx, my)

	-- TO-DO: add list of spells that can be clicked on

	if my < 10 then
		self.doShowSpellList = false
		subState = SubStates.IDLE
	end
	
end

function Renderer:showPlayerStats()
	
	self:drawText(251, 228,    "HEALTH")
	self:drawText(251, 228+14,    "MANA")
	self:drawText(251, 228+28, "ATK")
	self:drawText(251, 228+42, "DEF")
	
	self:drawText(364, 228, "GOLD")
	self:drawText(364, 228+14, "ANT SACS")

	self:drawText(316, 228,    ": " .. party.stats.health)
	self:drawText(316, 228+14,    ": " .. party.stats.mana)
	self:drawText(316, 228+28, ": " .. party.stats.attack)
	self:drawText(316, 228+42, ": " .. party.stats.defence)

	self:drawText(364+65, 228, ": " .. party.gold)
	self:drawText(364+65, 228+14, ": " .. party.antsacs)
	
end

function Renderer:showItemHoverStats(item)
		
	if item and assets.itemicons[item.id] then

		local mx, my = love.mouse.getPosition()

		local str = ""
		for key,value in pairs(item.modifiers) do
			local mod = item.modifiers[key]
			str = str .. key:upper() .. ": " .. value .. "   "
		end

		local statslen = assets.fonts["main"]:getWidth(str.trim(str))+15
		local namelen = assets.fonts["main"]:getWidth(item.name.trim(item.name))+15

		local l = namelen

		if namelen < statslen then
			l = statslen
		end

		if mx + l + 15 > screen.width then
			mx = screen.width - (l + 15)
		end
		
		love.graphics.setColor(0,0,0,0.75)
		love.graphics.rectangle("fill",mx+10,my-40, l, 40)
		love.graphics.setColor(1,1,1,1)
		
		self:drawWrappedText(mx+15, my-35, item.name, 263, {255/255,240/255,137/255,1})
		
		if str ~= "" then
			self:drawWrappedText(mx+15, my-20, str, 263, {1,1,1,1})
		end
		
	end
	
end

function Renderer:drawMinimap()

	self:drawText(10, 340, tostring(love.timer.getFPS()))

	love.graphics.setColor(1,1,1,1)

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

	--self:drawText(10, 10, direction_names[party.direction])
	
	love.graphics.setColor(1,1,1,1)

	love.graphics.draw(assets.images["main-ui"], 0,0)
	
	-- left hand

	local leftHand = party:getLeftHand()
	
	if leftHand then
		love.graphics.draw(assets.itemicons[leftHand.id], 280,323)
	end
	
	if party:hasCooldown(1) then
		love.graphics.draw(assets.images["cooldown-overlay"], 278,321)
	end
	
	local rightHand = party:getrightHand()

	if rightHand then
		love.graphics.draw(assets.itemicons[rightHand.id], 328,323)
	end

	if party:hasCooldown(2) then
		love.graphics.draw(assets.images["cooldown-overlay"], 326,321)
	end

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
					highlightshader:send("WhiteFactor", 0.5)
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

function Renderer:isDraggingItem()

	return inventoryDragSource.item ~= nil
	
end

function Renderer:showInventory(value)

	assets:playSound("window-open")

	self.currentHoverItem = nuil

	inventoryDragSource = {}

	self.doShowInventory = value

	if not value then
		subState = SubStates.IDLE
	else
		subState = SubStates.INVENTORY
	end
	
end

function Renderer:showing()

	return self.doShowInventory

end

function Renderer:onCloseButtonClick()

	renderer:showInventory(false)

end

function Renderer:showSpellList()

	self.doShowSpellList = true

end

return Renderer
