local Enemy = class('Enemy')

local EnemyState = {
	INIT = 0,
	WANDER = 1,
	TRACKING = 2,
	ATTACKING = 3
}

function Enemy:initialize(enemy)
	
	local map = {
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	}
	
	self.enemy = enemy
	self.enemy.properties.attacking = 0
	
	self.pathFinder = {}
	self.pathFinder = Pathfinder(Grid(map), 'ASTAR', 0)
	self.pathFinder:setHeuristic('MANHATTAN')
	self.pathFinder:setMode('ORTHOGONAL')
	self.path = nil
	
	self.tickDelay = 1
	self.attackDelay = 2
	self.tickCounter = math.random()
	self.attackCounter = math.random()
	
	self.state = EnemyState.INIT
	
end	

function Enemy:setMap(map)

	self.map = map
	self.pathFinder:setGrid(Grid(map))
	self.state = EnemyState.WANDER
	
end

function Enemy:update(dt)
	

	if self.state == EnemyState.ATTACKING then

		if self.attackCounter > self.attackDelay then

			self.attackCounter = 0

			-- make sure enemy can't attack if player has just left
			
			if distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y) <= 1 then
				assets:playSound("ant-attack")
				self:facePlayer()
				self.enemy.properties.attacking = 1
			end

			-- see if player left and calculate new tracking path
			
			if self:calcPathToPlayerPosition() then
				if self.pathlength > 1 then
					self.enemy.properties.attacking = 0
					self.state = EnemyState.TRACKING
				end
			end				
		end
		
		if self.attackCounter > 0.5 then
			self.enemy.properties.attacking = 0
		end
		
		self.attackCounter = self.attackCounter + dt
		
	end
		
	if self.tickCounter > self.tickDelay then

		self.tickCounter = 0

		if self.state == EnemyState.WANDER then
		
			if self:canSeePlayer() then
				if self:calcPathToPlayerPosition() then
					self.state = EnemyState.TRACKING
				end
			else
				self:wander()
			end	
		
		end

		if self.state == EnemyState.TRACKING then
			if self:calcPathToPlayerPosition() then
				if self:walkToNextPathNode() then
				end
			else 
				self.state = EnemyState.WANDER
			end
		end
		
	end

	self.tickCounter = self.tickCounter + dt;

end

function Enemy:calcPathToPlayerPosition()

	self.path = self.pathFinder:getPath(self.enemy.x,self.enemy.y, party.x,party.y)
	
	if self.path then
		self.pathlength = self.path:getLength()
		if self.pathlength < 7 then
			self.pathNodeIndex = 2
			return true
		end
	end

	self.path = nil

	return false
	
end

function Enemy:canSeePlayer()

	local distance = distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y)
	
	if distance < 5 then
		return bresenham.los(party.x, party.y, self.enemy.x, self.enemy.y, function(x, y)
				return self.map[y][x] == 0
		end)	
	end
	
	return false

end

function Enemy:walkToNextPathNode()

	-- no path

	if not self.path then
		return false
	end	

	-- reached end of path

	if self.pathNodeIndex > self.pathlength then
		self.state = EnemyState.ATTACKING
		self.attackCounter = 1.0 + (math.random()*2)
		self.path = nil
		return false
	end

	-- follow the path

	local stepindex = 1

	for node, count in self.path:nodes() do
		if stepindex == self.pathNodeIndex then

			local nx = node:getX()
			local ny = node:getY()

			-- check if enemy in the way

			for key,value in pairs(level.data.enemies) do
				if level.data.enemies[key].x == nx and level.data.enemies[key].y == ny then
					self.path = nil
					return false
				end
			end
			
			self.enemy.x = nx
			self.enemy.y = ny
			
			if distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y) < 5 then
				assets:playSound("ant-move")
			end
			
			local dir = 0
			if party.x > nx then dir = 1
			elseif party.x < nx then dir = 3 
			elseif party.y > ny then dir = 2 
			elseif party.y < ny then dir = 0 end
			
			self.enemy.properties.direction = dir
			self.pathNodeIndex = self.pathNodeIndex + 1
			
			return true
		
		end
		
		stepindex = stepindex + 1
		
	end

	return false
		
end

function Enemy:directionVectorOffsets()

    if self.enemy.properties.direction == 0 then
        return { x = self.enemy.x, y = self.enemy.y - 1 };
	elseif self.enemy.properties.direction == 1 then
		return { x = self.enemy.x + 1, y = self.enemy.y };
	elseif self.enemy.properties.direction == 2 then
		return { x = self.enemy.x, y = self.enemy.y + 1 };
	elseif self.enemy.properties.direction == 3 then
		return { x = self.enemy.x - 1, y = self.enemy.y };
	end

end

function Enemy:canWalk(x,y)

	if level.data.walls and level.data.walls[x][y] then

		if level.data.walls[x][y].type == 1 then
			return false
		end

		if level.data.walls[x][y].type == 2 then
			return false
		end
	
	end

	if level.data.boundarywalls and level.data.boundarywalls[x] and level.data.boundarywalls[x][y] then
		return false
	end
	
	if level:getObject(level.data.enemyblockers, x,y) then return false end	
	if level:getObject(level.data.enemies, x,y) then return false end	
	if level:getObject(level.data.doors, x,y) then return false end	
	if level:getObject(level.data.portals, x,y) then return false end
	if level:getObject(level.data.npcs, x,y) then return false end
	if level:getObject(level.data.chests, x,y) then	return false end
	if level:getObject(level.data.wells, x,y) then return false	end	
	if level:getObject(level.data.staticprops, x,y) then return false end		
	
	return true

end

function Enemy:isEnemyAt(x, y)

	if level:getObject(level.data.enemies, x,y) then return true end	

	return false

end

function Enemy:wander()

	-- 25% chance to turn around

	if math.random() < 0.25 then
		self.enemy.properties.direction = math.floor(math.random()*4)
		return
	end

	-- 25% chance to move if the enemy is a wanderer

	if self.enemy.properties.wanderer == 1 then

		if math.random() < 0.75 then
		
			local p = self:directionVectorOffsets()
			
			-- first check if there is an enemy in that direction. if there is then try to move in opposite direction
			
			if self:isEnemyAt(p.x,p.y) then
				self.enemy.properties.direction = self.enemy.properties.direction + 2
				if self.enemy.properties.direction > 3 then
					self.enemy.properties.direction = (self.enemy.properties.direction - 4)
				end
			end
			
			if self:canWalk(p.x,p.y) then
				if distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y) < 5 then
					assets:playSound("ant-move")
				end			
				self.enemy.x = p.x
				self.enemy.y = p.y
				return
			end
			
		end

	end

end

function Enemy:facePlayer()

	if party.x > self.enemy.x then self.enemy.properties.direction = 1 return end
	if party.x < self.enemy.x then self.enemy.properties.direction = 3 return end
	if party.y > self.enemy.y then self.enemy.properties.direction = 2 return end
	if party.y < self.enemy.y then self.enemy.properties.direction = 0 return end

end

return Enemy
