local Level = class('Level')

function Level:initialize()
	
	self.data = {}
	self.fonts = {}
	self.jsondata = {}
	self.loaded = false
	
end

function Level:load(id, door)

	local numerrors = 0

	self.loaded = false

	-- load level data

	file, err = io.open("files/areas/"..id..".lua", "rb")
	
	if not err and file then
	
		local leveldata = file:read("*all")
		file:close()
	
		self.data = lume.deserialize(leveldata)

		if door then
			party.x = door.properties.targetx+1
			party.y = door.properties.targety+1
			party.direction = door.properties.targetdir
		else
			party.x = self.data.partyX
			party.y = self.data.partyY
			party.direction = self.data.partyDirection
		end
		
		if not self.data.boundarywalls then
			self.data.boundarywalls = {}
		end
		
		-- randomize enemy facing direction
		
		for key,value in pairs(self.data.enemies) do
			local enemy = level.data.enemies[key]
			enemy.properties.direction = math.floor(math.random()*4)
		end
		
		self:applyGlobalVariables()

	else
		numerrors = numerrors + 1
	end

	return (numerrors == 0)

end

function Level:applyVars(vars)

	if vars == "" then
		return
	end

	-- First split the vars string on | symbol

	if string.sub(vars,#vars,#vars) ~= "|" then
		vars = vars.."|"
	end
			
	tokens = {}
	for w in vars:gmatch("([^|]*[|])") do
		if string.sub(w,#w,#w) == "|" then
			w = string.sub(w,1,#w-1)
		end
		table.insert(tokens, w)
	end		

	-- Then split each var on the : symbol

	for i = 1,#tokens do

		local var = tokens[i]

		if string.sub(var,#var,#var) ~= ":" then
			var = var..":"
		end
				
		segments = {}
		for w in var:gmatch("([^:]*[:])") do
			if string.sub(w,#w,#w) == ":" then
				w = string.sub(w,1,#w-1)
			end
			table.insert(segments, w)
		end	

		globalvariables:add(segments[1], segments[2], segments[3])

	end

	self:applyGlobalVariables()

end

function Level:applyGlobalVariables()

	for key,value in pairs(self.data.enemies) do
		
		local enemy = level.data.enemies[key]

		local gvar = globalvariables:get(enemy.properties.id, "state")
		if gvar then enemy.properties.state = tonumber(gvar) end		

		gvar = globalvariables:get(enemy.properties.id, "x")
		if gvar then enemy.x = tonumber(gvar) end		
		
		gvar = globalvariables:get(enemy.properties.id, "y")
		if gvar then enemy.y = tonumber(gvar) end		
		
		gvar = globalvariables:get(enemy.properties.id, "direction")
		if gvar then enemy.properties.direction = tonumber(gvar) end		
		
	end
	
	for key,value in pairs(self.data.triggers) do
		
		local trigger = level.data.triggers[key]

		local gvar = globalvariables:get(trigger.properties.id, "state")
		if gvar then trigger.properties.state = tonumber(gvar) end		

	end	
	
	for key,value in pairs(self.data.staticprops) do
		
		local prop = level.data.staticprops[key]

		local gvar = globalvariables:get(prop.properties.id, "state")
		if gvar then prop.properties.state = tonumber(gvar) end		

		local gvar = globalvariables:get(prop.properties.id, "visible")
		if gvar then prop.properties.visible = tonumber(gvar) end		

	end		
	
	for key,value in pairs(self.data.portals) do
		
		local portal = level.data.portals[key]

		local gvar = globalvariables:get(portal.properties.id, "state")
		if gvar then portal.properties.state = tonumber(gvar) end		

	end	
	
	for key,value in pairs(self.data.npcs) do
		
		local npc = level.data.npcs[key]

		local gvar = globalvariables:get(npc.properties.id, "state")
		if gvar then npc.properties.state = tonumber(gvar) end		
		
		local gvar = globalvariables:get(npc.properties.id, "visible")
		if gvar then npc.properties.visible = tonumber(gvar) end		

	end	
	
	for key,value in pairs(self.data.wells) do
		
		local well = level.data.wells[key]

		local gvar = globalvariables:get(well.properties.id, "state")
		if gvar then well.properties.state = tonumber(gvar) end		
		
		local gvar = globalvariables:get(well.properties.id, "counter")
		if gvar then
			well.properties.counter = tonumber(gvar)
		else
			well.properties.counter = 0
		end

	end		
	
	for key,value in pairs(self.data.doors) do
		
		local door = level.data.doors[key]

		local gvar = globalvariables:get(door.properties.id, "state")
		if gvar then door.properties.state = tonumber(gvar) end		
		
		local gvar = globalvariables:get(door.properties.id, "keyid")
		if gvar then door.properties.keyid = tostring(gvar) end		

	end	
	
	for key,value in pairs(self.data.chests) do
		
		local chest = level.data.chests[key]

		local gvar = globalvariables:get(chest.properties.id, "state")
		if gvar then chest.properties.state = tonumber(gvar) end		
		
		local gvar = globalvariables:get(chest.properties.id, "keyid")
		if gvar then chest.properties.keyid = tostring(gvar) end		

	end	
	
	for key,value in pairs(self.data.buttons) do
		
		local button = level.data.buttons[key]

		local gvar = globalvariables:get(button.properties.id, "state")
		if gvar then button.properties.button = tonumber(gvar) end		

	end		
	
end

function Level:getObject(t, x, y)

	if t then
		for key,value in pairs(t) do
			if t[key].x == x and t[key].y == y then
				return t[key]
			end
		end
	end

	return nil

end

function Level:generatePathMap()

	local map = {}

	for y = 1, self.data.mapSize do
		map[y] = {}
		for x = 1, self.data.mapSize do
			
			local walkable = 0

			if self.data.walls[x] and self.data.walls[x][y] then
				if  self.data.walls[x][y].type == 1 then
					walkable = 1
				end
			end

			if self.data.boundarywalls[x] and self.data.boundarywalls[x][y] then
				walkable = 1
			end

			for key,value in pairs(self.data.staticprops) do
				local prop = self.data.staticprops[key]
				if prop.x == x and prop.y == y then
					walkable = 1
				end
			end		

			for key,value in pairs(self.data.npcs) do
				local npc = self.data.npcs[key]
				if npc.x == x and npc.y == y then
					walkable = 1
				end
			end	
		
			for key,value in pairs(self.data.chests) do
				local chest = self.data.chests[key]
				if chest.x == nx and chest.y == ny then
					walkable = 1
				end
			end

			for key,value in pairs(self.data.wells) do
				local well = self.data.wells[key]
				if well.x == nx and well.y == ny then
					walkable = 1
				end
			end
			
			for key,value in pairs(self.data.doors) do
				local door = self.data.doors[key]
				if door.x == nx and door.y == ny then
					walkable = 1
				end
			end
			
			for key,value in pairs(self.data.portals) do
				local portal = level.data.portals[key]
				if portal.x == nx and portal.y == ny then
					walkable = 1
				end
			end	
		
			table.insert(map[y], walkable) 
		
		end
	end

	return map

end

function Level:getFacingEnemy()

	local x, y

	local adjancentSquare =  {
		[0] = {x = 0, y = -1},
		[1] = {x = 1, y = 0},
		[2] = {x = 0, y = 1},
		[3] = {x = -1, y = 0}
	}

	local x = party.x + adjancentSquare[party.direction].x
	local y = party.y + adjancentSquare[party.direction].y

	local enemy = self:getObject(self.data.enemies, x,y)

	if enemy and enemy.properties.state == 1 then
		return enemy
	end
	
	return nil

end

function Level:getFacingObject(t, x, y)

	local adjancentSquare =  {
		[0] = {x = 0, y = -1},
		[1] = {x = 1, y = 0},
		[2] = {x = 0, y = 1},
		[3] = {x = -1, y = 0}
	}

	local x = party.x + adjancentSquare[party.direction].x
	local y = party.y + adjancentSquare[party.direction].y

	if t then
		for key,value in pairs(t) do
			if t[key].x == x and t[key].y == y then
				return t[key]
			end
		end
	end

	return nil

end

return Level
