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

	--[[

	for y = 1, self.data.mapSize do
		for x = 1, self.data.mapSize do
			-- Doors
			if self.data.doors[x] and self.data.doors[x][y] then
				local gvar = globalvariables:get(self.data.doors[x][y].id, "state")
				if gvar then
					self.data.doors[x][y].state = tonumber(gvar)
				end
			end
			-- Encounters
			if self.data.encounters[x] and self.data.encounters[x][y] then
				local gvar = globalvariables:get(self.data.encounters[x][y].id, "state")
				if gvar then
					self.data.encounters[x][y].state = tonumber(gvar)
				end
			end		
			-- Triggers
			if self.data.triggers[x] and self.data.triggers[x][y] then
				local gvar = globalvariables:get(self.data.triggers[x][y].id, "state")
				if gvar then
					self.data.triggers[x][y].state = tonumber(gvar)
				end
			end	
			-- Spinners
			if self.data.spinners[x] and self.data.spinners[x][y] then
				local gvar = globalvariables:get(self.data.spinners[x][y].id, "state")
				if gvar then
					self.data.spinners[x][y].state = tonumber(gvar)
				end
			end	
			-- Buttons
			if self.data.buttons[x] and self.data.buttons[x][y] then
				local gvar = globalvariables:get(self.data.buttons[x][y].id, "state")
				if gvar then
					self.data.buttons[x][y].state = tonumber(gvar)
				end
			end		
			-- Portals
			if self.data.portals[x] and self.data.portals[x][y] then
				local gvar = globalvariables:get(self.data.portals[x][y].id, "state")
				if gvar then
					self.data.portals[x][y].state = tonumber(gvar)
				end
			end		
			-- NPCS
			if self.data.npcs[x] and self.data.npcs[x][y] then
				local gvar = globalvariables:get(self.data.npcs[x][y].id, "state")
				if gvar then
					self.data.npcs[x][y].state = tonumber(gvar)
				end
			end				
			-- Chests
			if self.data.chests[x] and self.data.chests[x][y] then
				local gvar = globalvariables:get(self.data.chests[x][y].id, "state")
				if gvar then
					self.data.chests[x][y].state = tonumber(gvar)
				end
			end				
		end
	end	
	
	]]--
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
				walkable = 1
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

return Level
