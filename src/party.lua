local Party = class('Party')

function Party:initialize()

	self.direction = 0
	self.x = 1
	self.y = 1
	self.gold = 0

	self.stats =  {
		attack = 10,
		defence = 1,
		health = 100,
		health_max = 100,
	}

	self.cooldownDelays = {[1] = 2, [2] = 4}
	self.cooldownCounters = {[1] = 0, [2] = 0}

end

function Party:update(dt)

	for i = 1,#self.cooldownCounters do
		if self.cooldownCounters[i] > 0 then
			self.cooldownCounters[i] = self.cooldownCounters[i] - dt
			if self.cooldownCounters[i] <= 0 then
				self.cooldownCounters[i] = 0
			end
		end
	end

end

function Party:attack(handId, enemies)

	if self.cooldownCounters[handId] > 0 then
		return
	end

	self.cooldownCounters[handId] = self.cooldownDelays[handId]

	for i = 1,#self.cooldownCounters do
		print(self.cooldownCounters[i])
	end
	
	local enemy = level:getFacingEnemy()
	
	if not enemy then
		if handId == 1 then
			assets:playSound("player-miss")
		end
		return
	end


	local damage

	-- attack with left hand (melee)
	
	if handId == 1 then
	
		-- there is always a small chance that there will be a miss in melee
		
		if math.random() > 0.75 then
			assets:playSound("player-miss")
			return
		end
		
		assets:playSound("player-attack")
		
		damage = 2 * math.pow(party.stats.attack, 2) / (party.stats.attack + enemy.properties.defence)
		
		damage = randomizeDamage(damage)
	
	end

	-- attack with right hand (spell)

	if handId == 2 then
	
		assets:playSound("player-attack")
		
		damage = 2 * math.pow(party.stats.attack, 2) / (party.stats.attack + enemy.properties.defence)
		
		damage = randomizeDamage(damage)
	
	end
	
	print("Player:" .. damage)

	enemy.properties.health = enemy.properties.health - damage
	
	for i = 1, #enemies do
		if enemies[i].enemy == enemy then
			enemies[i]:showHighlight()
		end
	end
		
	if enemy.properties.health <= 0 then
		assets:playSound(enemy.properties.sound_die)
		globalvariables:add(enemy.properties.id, "state", 2)
		enemy.properties.state = 2
		
		for i = 1, #enemies do
			if enemies[i].enemy == enemy then
				enemies[i]:die()
			end
		end
	end
	
end

function Party:hasCooldown(handId)

	return self.cooldownCounters[handId] > 0

end

function Party:died()

	love.event.quit()
	
end

return Party