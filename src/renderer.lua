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
	self.doShowAutomapper = false
	self.doShowInventory = false
	self.currentHoverItem = nil
	self.doShowSpellList = false
	
	self.popupText = ""
	
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
	
	self.menuitems = {
		{ x = 512, y = 110, caption = "Start game", trigger = self.onStartButtonClick},
		{ x = 512, y = 110 + 30, caption = "Settings", trigger = self.onSettingsButtonClick},
		{ x = 512, y = 110 + 60, caption = "Credits", trigger = self.onCreditsButtonClick},
		{ x = 512, y = 110 + 90, caption = "About", trigger = self.onAboutButtonClick},
		{ x = 512, y = 110 + 120, caption = "Quit", trigger = self.onQuitButtonClick}
	}	
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

		if self.doShowAutomapper then
			self:drawAutomapper()
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
		self:drawMainmenu()
	end
	
	if gameState == GameStates.CREDITS then
		self:drawCredits()
	end	
	
	if gameState == GameStates.ABOUT then
		self:drawAbout()
	end		

	if gameState == GameStates.SETTINGS then
		self:drawSettings()
	end		
	
	if subState == SubStates.POPUP then
		self:drawPopup()
	end
	
	if gameState == GameStates.EXPLORING or gameState == GameStates.MAIN_MENU or gameState == GameStates.CREDITS then
		self:drawPointer()	
	end
	
	if self.currentHoverItem then
		self:showItemHoverStats(self.currentHoverItem)
	end
	
	local mx, my = love.mouse.getPosition()
	self:drawText(10,10, mx .. "/" .. my, {1,1,1,1})
	
	love.graphics.setCanvas()

end

function Renderer:handleMousePressed(x, y, button)
	
	if button == 1 then

		if subState == SubStates.INVENTORY then

			if self.doShowInventory then
				self:clickOnInventory(x, y)
				return
			end
		
		end
		
		if subState == SubStates.POPUP then
			subState = SubStates.IDLE
		end
		
		if subState == SubStates.AUTOMAPPER then
			if intersect(x, y, 587, 321, 34, 34) then
				self:showAutomapper(false)
			end
		end
		
		if gameState == GameStates.MAIN_MENU then
			for i = 1, #self.menuitems do
				if intersect(x, y, self.menuitems[i].x, self.menuitems[i].y, 100, 20) then
					self.menuitems[i].trigger()
				end
			end		
			return
		end
		
		if gameState == GameStates.CREDITS or gameState == GameStates.ABOUT then
			gameState = GameStates.MAIN_MENU
			return
		end

		if gameState == GameStates.SETTINGS then
			gameState = GameStates.MAIN_MENU
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

	if subState == SubStates.INVENTORY then
	
		if key == 'i' then
			self:showInventory(false)
			return
		end

	end
	
	if subState == SubStates.AUTOMAPPER then
	
		if key == 'm' then
			self:showAutomapper(false)
			return
		end

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

function Renderer:drawText(x, y, text, color, align)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x+1, y+1, 640, align)
	love.graphics.setColor(color)
	love.graphics.printf(text, x, y, 640, align)
	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawWrappedText(x, y, text, wrapAt, color, align)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x+1, y+1, wrapAt, align)
	love.graphics.setColor(color)
	love.graphics.printf(text, x, y, wrapAt, align)
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
	
	if inventoryDragSource.item and assets.itemicons[inventoryDragSource.item.id] then
		love.graphics.draw(assets.itemicons[inventoryDragSource.item.id], x-16, y-16)
	else
		love.graphics.draw(assets.images["pointer"], x, y)
	end
	
end

function Renderer:drawPopup()

	love.graphics.draw(assets.images["popup-background"], 194, 100)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	width, wrappedtext = assets.fonts["mainmenu"]:getWrap(self.popupText, 232)

	local offsety = 143

	if #wrappedtext > 1 then
		offsety = offsety - math.floor((#wrappedtext*16)/2)
	else
		offsety = offsety - 8
	end

	for i = 1, #wrappedtext do
		self:drawText(0,offsety + (i-1)*16, wrappedtext[i], {1,1,1,1}, "center")
	end

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawCredits()

	love.graphics.draw(assets.images["credits-background"], 0, 0)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	self:drawText(152,24, "Code & Art*", {1,1,1,1})
	self:drawText(414,24, "Music", {1,1,1,1})


	self:drawText(143,174, "Dan Thoresen", {1,1,1,1})
	self:drawText(388,174, "Travis Sullivan", {1,1,1,1})

	self:drawText(140,224, "zooperdan", {1,1,1,1})
	self:drawText(140,256, "zooperdan.itch.io", {1,1,1,1})
	self:drawText(140,288, "dungeoncrawlers.org", {1,1,1,1})

	self:drawText(378,224, "SullyMusic", {1,1,1,1})
	self:drawText(378,256, "travisoraziosullivan", {1,1,1,1})
	self:drawText(378,288, "travissullivan.com/composer/", {1,1,1,1})

	self:drawText(0,340, "* Refer to attribution.txt for more information", {1,1,1,.25}, "center")

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawAbout()

	self:drawText(0, 40, "- ABOUT -", {1,1,1,1}, "center")

end

function Renderer:drawSettings()

	self:drawText(0, 40, "- SETTINGS -", {1,1,1,1}, "center")

end

function Renderer:drawSpellList()

	self:drawText(20, 200, "SELECT SPELL", {1,1,1,1})

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
			if inventoryDragSource.item then
				love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
			else
				if party.equipmentslots[i].id ~= "" then
					love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
					self.currentHoverItem = itemtemplates:get(party.equipmentslots[i].id)
				end
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
	end
	
	-- inventory slots

	hovercell = nil

	for row = 1, 5 do
		for col = 1, 8 do
		
			local x = settings.inventorySlotsStartX + (col-1) * slotsize
			local y = settings.inventorySlotsStartY + (row-1) * slotsize
			
			-- draw slot highlight
			
			if intersect(mx, my, x, y, slotsize, slotsize) then
				if inventoryDragSource.item then
					love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
				else
					if party.inventory[row][col] ~= "" then
						love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
						self.currentHoverItem = itemtemplates:get(party.inventory[row][col])
					end
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
	end
	
end

function Renderer:clickOnInventory(mx, my)

	if not inventoryDragSource.item then
		if self.buttons["close"]:isOver(mx, my) then
			self.buttons["close"].trigger()
		end
	end

	local slotsize = 33

	-- inventory button in main ui
	
	if not inventoryDragSource.item and intersect(mx, my, 19, 321, 34, 34) then
		if not self:inventoryShowing() then
			self:showInventory(true)
			return
		else
			self:showInventory(false)
			return
		end
	end		

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

function Renderer:drawMainmenu()

	local mx, my = love.mouse.getPosition()

	love.graphics.draw(assets.images["mainmenu-background"], 0, 0)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	for i = 1, #self.menuitems do
	
		if intersect(mx, my, self.menuitems[i].x, self.menuitems[i].y, 100, 20) then
			self:drawText(self.menuitems[i].x, self.menuitems[i].y, self.menuitems[i].caption, {1,1,1,1})
		else
			self:drawText(self.menuitems[i].x, self.menuitems[i].y, self.menuitems[i].caption, {1.0,.85,.75,1})
		end
	
	end

	love.graphics.setFont(assets.fonts["main"]);

	love.graphics.setColor(1,1,1,1)

end

function Renderer:onSpellSelect(mx, my)

	-- TO-DO: add list of spells that can be clicked on

	if my < 10 then
		self.doShowSpellList = false
		subState = SubStates.IDLE
	end
	
end

function Renderer:showPlayerStats()
	
	self:drawText(251, 228,    "HEALTH", {1,1,1,1})
	self:drawText(251, 228+14,    "MANA", {1,1,1,1})
	self:drawText(251, 228+28, "ATK", {1,1,1,1})
	self:drawText(251, 228+42, "DEF", {1,1,1,1})
	
	self:drawText(364, 228, "GOLD", {1,1,1,1})
	self:drawText(364, 228+14, "ANT SACS", {1,1,1,1})

	self:drawText(316, 228,    ": " .. party.stats.health, {1,1,1,1})
	self:drawText(316, 228+14,    ": " .. party.stats.mana, {1,1,1,1})
	self:drawText(316, 228+28, ": " .. party.stats.attack, {1,1,1,1})
	self:drawText(316, 228+42, ": " .. party.stats.defence, {1,1,1,1})

	self:drawText(364+65, 228, ": " .. party.gold, {1,1,1,1})
	self:drawText(364+65, 228+14, ": " .. party.antsacs, {1,1,1,1})
	
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
		
		self:drawText(mx+15, my-35, item.name, {255/255,240/255,137/255,1})
		
		if str ~= "" then
			self:drawText(mx+15, my-20, str, {1,1,1,1})
		end
		
	end
	
end

function Renderer:drawAutomapper()

	self:drawText(10, 340, tostring(love.timer.getFPS()), {1,1,1,1})

	love.graphics.setColor(1,1,1,1)

	local cellsize = 6
	local offsetx = 222+2
	local offsety = 39+2

	love.graphics.draw(assets.images["automapper-background"], 222, 39)
	
	for y = 1, level.data.mapSize do
		for x = 1, level.data.mapSize do
		
			local dx = offsetx + ((x-1) * cellsize)
			local dy = offsety + ((y-1) * cellsize)
		
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

	love.graphics.setColor(1,1,1,1)

	-- main ui

	love.graphics.draw(assets.images["main-ui"], 0,0)
	
	-- compass
	
	love.graphics.draw(assets.images["compass"], assets.compass_quads[party.direction], 318, 7)

	
	-- left hand

	local leftHand = party:getLeftHand()
	
	if leftHand then
		love.graphics.draw(assets.itemicons[leftHand.id], 282,321)
	else
		love.graphics.draw(assets.images["lefthand-background"], 282,321)
	end
	
	if party:hasCooldown(1) then
		love.graphics.draw(assets.images["cooldown-overlay"], 283,322)
	end
	
	-- right hand
	
	local rightHand = party:getrightHand()

	if rightHand then
		love.graphics.draw(assets.itemicons[rightHand.id], 329,321)
	else
		love.graphics.draw(assets.images["spellbook-background"], 329,321)
	end

	if party:hasCooldown(2) then
		love.graphics.draw(assets.images["cooldown-overlay"], 330,322)
	end

	-- healing potions

	if party.healing_potions > 0 then
		love.graphics.draw(assets.itemicons["healing-potion"], 239,325)
		local x,y = 262, 347
		if party.healing_potions < 10 then
			love.graphics.draw(assets.images["digits"], assets.digit_quads[party.healing_potions], x, y)
		else
			local str = tostring(party.healing_potions)
			local x,y = 262 - (#str*6), 347
			for i = 1, #str do
				local c = tonumber(string.sub(str,i,i))
				love.graphics.draw(assets.images["digits"], assets.digit_quads[c], x + (i*6), y)
			end
		end
		
		if party:hasCooldown(3) then
			love.graphics.draw(assets.images["cooldown-overlay"], 240,326)
		end
		
	end


	-- mana potions

	if party.mana_potions > 0 then
		love.graphics.draw(assets.itemicons["mana-potion"], 372,325)
		local x,y = 395, 347
		if party.mana_potions < 10 then
			love.graphics.draw(assets.images["digits"], assets.digit_quads[party.mana_potions], x, y)
		else
			local str = tostring(party.mana_potions)
			local x,y = 395 - (#str*6), 347
			for i = 1, #str do
				local c = tonumber(string.sub(str,i,i))
				love.graphics.draw(assets.images["digits"], assets.digit_quads[c], x + (i*6), y)
			end
		end
		
		if party:hasCooldown(4) then
			love.graphics.draw(assets.images["cooldown-overlay"], 373,326)
		end
		
	end

	-- health and mana bars
	
	self:drawBar(164-2, 348-2, party.stats.health, party.stats.health_max, 62, 1)
	self:drawBar(413-2, 348-2, party.stats.mana, party.stats.mana_max, 62, 2)
	

end

function Renderer:drawEnemyStats(enemy)

	self:drawText(0, 10+50, enemy.properties.name, {1,1,1,1}, "center")
	
	local x = math.floor(screen.width/2 - assets.images["enemy-hit-bar-background"]:getWidth()/2)
	local y = 30+50
	
	love.graphics.draw(assets.images["enemy-hit-bar-background"], x, y)

	if enemy.properties.health > 0 then
		self:drawBar(x, y, enemy.properties.health, enemy.properties.health_max, 143, 1)
	end

end

function Renderer:drawBar(x, y, maxval, minval, maxbarsize, bartype)

	local f = maxval/minval
	local barsize = maxbarsize * f
	local quad = nil

	local offs = 3

	local img = assets.images["bar-type-1"]

	if bartype == 2 then
		img = assets.images["bar-type-2"]
	end

	-- bar body
	quad = love.graphics.newQuad(1, 0, 1, 5, img:getWidth(), img:getHeight())
	love.graphics.draw(img, quad, x + offs, y + offs, 0, barsize, 1)

	-- left edge
	
	quad = love.graphics.newQuad(0, 0, 1, 5, img:getWidth(), img:getHeight())
	love.graphics.draw(img, quad, x + offs, y + offs)

	-- right edge
	
	quad = love.graphics.newQuad(2, 2, 1, 5, img:getWidth(), img:getHeight())
	love.graphics.draw(img, quad, (x + offs) + (barsize-1), y + offs)
	
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

function Renderer:showAutomapper(value)

	assets:playSound("window-open")

	self.doShowAutomapper = value

	if not value then
		subState = SubStates.IDLE
	else
		subState = SubStates.AUTOMAPPER
	end
					
end

function Renderer:inventoryShowing()

	return self.doShowInventory

end

function Renderer:automapperShowing()

	return self.doShowAutomapper

end

function Renderer:onCloseButtonClick()

	renderer:showInventory(false)

end

function Renderer:onStartButtonClick()
	Game:startGame()
end

function Renderer:onSettingsButtonClick()

	gameState = GameStates.SETTINGS

end

function Renderer:onCreditsButtonClick()

	gameState = GameStates.CREDITS

end

function Renderer:onAboutButtonClick()

	gameState = GameStates.ABOUT

end

function Renderer:onQuitButtonClick()

	love.event.quit()

end


function Renderer:showPopup(text)

	assets:playSound("popup")
	self.popupText = text
	subState = SubStates.POPUP
	
end

function Renderer:showSpellList()

	self.doShowSpellList = true

end

return Renderer
