local Party = class('Party')

function Party:initialize()

	self.leftHandSlotIndex = 7
	self.rightHandSlotIndex = 5

	self.direction = 0
	self.x = 1
	self.y = 1
	self.gold = 0
	self.antsacs = 0
	self.healing_potions = 0
	self.mana_potions = 0
	
	self.basestats =  {
		attack = 1,
		defence = 1,
		health_max = 100,
		mana_max = 100,
	}
	
	self.stats =  {
		attack = 1,
		defence = 1,
		health = 100,
		health_max = 100,
		mana = 100,
		mana_max = 100,
	}

	self.cooldownDelays = {[1] = 2, [2] = 4, [3] = 8, [4] = 8}
	self.cooldownCounters = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}

	self.inventory = {
		{"sword-1", "sword-2", "dagger-1", "dagger-2", "axe-1", "axe-2", "armor-3", "armor-4"},
		{"club", "mace", "spellbook-1", "spellbook-2", "spellbook-3", "sword-3", "sword-4", "sword-5"},
		{"ring-1", "ring-2", "ring-3", "ring-4", "belt-1", "belt-2", "belt-3", "boots-1"},
		{"boots-2", "boots-3", "cape-1", "cape-2", "cape-3", "gloves-1", "gloves-2", "gloves-3"},
		{"helmet-1", "helmet-2", "helmet-3", "necklace-1", "necklace-2", "necklace-3", "armor-1", "armor-2"}
	}
	
	self.equipmentslots =  {
		{ id = "", type = "back", x = 7, y = 46 },
		{ id = "", type = "head", x = 46, y = 7 },
		{ id = "", type = "neck", x = 7, y = 7 },
		{ id = "", type = "torso", x = 46, y = 46 },
		{ id = "", type = "offhand", x = 7, y = 89 },
		{ id = "", type = "waist", x = 46, y = 89 },
		{ id = "sword-1", type = "weapon", x = 85, y = 89 },
		{ id = "", type = "hands", x = 85, y = 46 },
		{ id = "", type = "feet", x = 46, y = 163 },
		{ id = "", type = "finger", x = 7, y = 200 },
		{ id = "", type = "finger", x = 46, y = 200 },
		{ id = "", type = "finger", x = 85, y = 200 },
	}

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

function Party:attackWithMelee(enemies)

	local handId = 1

	-- check if still cooling down

	if self.cooldownCounters[handId] > 0 then
		return
	end

	-- make sure there is a weapon wielded
	
	local leftHand = party:getLeftHand()
	if not leftHand then return end

	self.cooldownCounters[handId] = self.cooldownDelays[handId]
	
	local enemy = level:getFacingEnemy()
	
	if not enemy then
		if handId == 1 then
			assets:playSound("player-miss")
		end
		return
	end

	local damage

	-- there is always a small chance that there will be a miss in melee
		
	if math.random() > 0.75 then
		assets:playSound("player-miss")
		return
	end
	
	assets:playSound("player-attack")
	
	damage = 2 * math.pow(party.stats.attack, 2) / (party.stats.attack + enemy.properties.defence)
	
	damage = randomizeDamage(damage)
	


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

function Party:updateStats()

	-- add the item modifiers
	
	local atk_mod = 0
	local def_mod = 0
	local hpmax_mod = 0
	local mpmax_mod = 0
	
	for i = 1, #self.equipmentslots do
		
		if self.equipmentslots[i].id ~= "" then
			
			local item = itemtemplates:get(self.equipmentslots[i].id)
			
			if item.modifiers.atk then atk_mod = atk_mod + item.modifiers.atk end
			if item.modifiers.def then def_mod =def_mod + item.modifiers.def end
			if item.modifiers.maxhp then hpmax_mod = hpmax_mod + item.modifiers.maxhp end
			if item.modifiers.maxmp then mpmax_mod = mpmax_mod + item.modifiers.maxmp end
			
		end
	
	end
	
	-- set the modified stats
	
	self.stats.attack = self.basestats.attack + atk_mod 
	self.stats.defence = self.basestats.defence + def_mod
	self.stats.health_max = self.basestats.health_max + hpmax_mod
	self.stats.mana_max = self.basestats.mana_max + mpmax_mod
	

end

function Party:addItem(id)

	for row = 1, 5 do
		for col = 1, 8 do
			if party.inventory[row][col] == "" then
				party.inventory[row][col] = id
				return
			end
		end
	end

	print("Inventory is full. Unable to add '" .. id .."'")

end

function Party:getLeftHand()

	if self.equipmentslots[self.leftHandSlotIndex].id ~= "" then
		return itemtemplates:get(self.equipmentslots[self.leftHandSlotIndex].id)
	else
		return nil
	end

end

function Party:getrightHand()

	if self.equipmentslots[self.rightHandSlotIndex].id ~= "" then
		return itemtemplates:get(self.equipmentslots[self.rightHandSlotIndex].id)
	else
		return nil
	end
	
end

function Party:usePotion(index)

	if index == 1 then

		if self.healing_potions <= 0 then return end
		
		if self.cooldownCounters[index+2] > 0 then
			return
		end

		self.cooldownCounters[index+2] = self.cooldownDelays[index+2]
		
		self.healing_potions = self.healing_potions - 1
		if self.healing_potions < 0 then self.healing_potions = 0 end
		self.stats.health = self.stats.health_max
		
	else
		
		if self.mana_potions <= 0 then return end
		
		if self.cooldownCounters[index+2] > 0 then
			return
		end

		self.cooldownCounters[index+2] = self.cooldownDelays[index+2]
		
		self.mana_potions = self.mana_potions - 1
		if self.mana_potions < 0 then self.mana_potions = 0 end
		self.stats.mana = self.stats.mana_max
		
	end
	
	assets:playSound("drink-potion")
	
end

return Party