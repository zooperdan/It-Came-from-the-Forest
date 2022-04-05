local CombatScreen = class('CombatScreen')

local CombatStates = {
	INIT = 0,
	PLAYER_TURN = 1,
	ENEMY_TURN = 2,
	VICTORY = 3,
	SELECT_TARGET = 4,
	BEFORE_ENEMY_TURN = 5,
	LOST_BATTLE = 6
}

local SubStates = {
	IDLE = 0,
	SELECT_SPELL = 1,
	SELECT_PLAYER_SPELL_TARGET = 2,
	SELECT_ENEMY_SPELL_TARGET = 3,
	SELECT_ENEMY_MELEE_TARGET = 4,
	SELECT_ENEMY_RANGED_TARGET = 5,
	EXCHANGE = 6,
	MOVE = 7,
	SELECT_ITEM = 8
}

function CombatScreen:initialize()
	
	self.enemyActDelay = 1
	self.enemyRoundDelay = 1
	
end

function CombatScreen:init(caller)
	
	self.caller = caller
	self.canvas = caller.canvas
	self.state = CombatStates.IDLE
	
end

function CombatScreen:show(encounter, ambush)

	ACTIVESCREEN = self

	self.encounter = encounter;
	self.state = CombatStates.INIT
	self.substate = SubStates.IDLE
	self.turnCharacterIndex = 1
	self.turnEnemyIndex = 1

	-- copy enemytemplates into local table

	self.enemies = {}
	self.experienceGained = 0
	
	for i = 1, #self.encounter.enemyids do
		local enemy = enemytemplates:get(self.encounter.enemyids[i])
		self.experienceGained = self.experienceGained + enemy.exp
		enemy.acted = false
		enemy.max_hps = enemy.hps
		enemy.max_mps = enemy.mps
		enemy.row = self.encounter.enemyrows[i]
		table.insert(self.enemies, enemy)
	end

	-- display combat start message
	
	self.ambushed = ambush
	
	self.showing = true
	
	if self.ambushed == 1 then
		messages:add("You have been ambushed. Get ready to fight!")
		self:enemyBeginTurn()
	else
		messages:add("You stumble upon some unsuspecting creatures!")
		self:playerBeginTurn()	
	end
	
end

function CombatScreen:update(dt)

	if self.state == CombatStates.ENEMY_TURN then

		if os.clock() > self.enemyActStart + self.enemyActDelay then
			local enemy = self:nextEnemy()
			if enemy then
				self:enemyAct()
			else
				self:playerBeginTurn()
			end
		end
	end

	if self.state == CombatStates.BEFORE_ENEMY_TURN then
		if os.clock() > self.enemyRoundStart + self.enemyRoundDelay then
			local enemy = self:nextEnemy()
			if enemy then
				self.state = CombatStates.ENEMY_TURN
				self.enemyActStart = os.clock()
				self:enemyAct()
			else
				self:playerBeginTurn()
			end
		end
	end
	
end

function CombatScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	love.graphics.draw(assets.images["screen_combat"], 11, 11)

	love.graphics.printf("Encounter!", 260, 8, 640, "left")

	-- draw front row enemies
	
	local yoffset = 40
	local y = 0
	local frontRow = getEnemiesInFrontRow(self.enemies)
	local backRow = getEnemiesInBackRow(self.enemies)
	
	for i = 1, #frontRow do
		
		local enemy = self.enemies[frontRow[i]]
		
		local prefix = enemyCanAct(enemy) and "" or "("
		local postfix = enemyCanAct(enemy) and "" or ")"
		love.graphics.printf("["..string.char(65+y).."] "..prefix..enemy.name..postfix, 260, yoffset+y*15, 740, "left")
		
		local enemyCondition = ENEMY_HEALTH_CONDITIONS[0] -- healthy
		if enemy.hps < enemy.max_hps * 0.90 then enemyCondition = ENEMY_HEALTH_CONDITIONS[1] end	-- injured
		if enemy.hps < enemy.max_hps * 0.75 then enemyCondition = ENEMY_HEALTH_CONDITIONS[2] end	-- hurt
		if enemy.hps < enemy.max_hps * 0.55 then enemyCondition = ENEMY_HEALTH_CONDITIONS[3] end	-- badly hurt
		if enemy.hps < enemy.max_hps * 0.15 then enemyCondition = ENEMY_HEALTH_CONDITIONS[4] end	-- almost dead
		
		love.graphics.printf(enemyCondition, -110, yoffset+y*15, 740, "right")
		
		y = y + 1
	end	
	
	-- draw back row enemies

	if #backRow >= 1 then

		love.graphics.draw(assets.images["dashed_line"], 262, (yoffset+y*15)-1)

		for i = 1, #backRow do

			local enemy = self.enemies[backRow[i]]
			
			local prefix = enemyCanAct(enemy) and "" or "("
			local postfix = enemyCanAct(enemy) and "" or ")"
			love.graphics.printf("["..string.char(65+y).."] "..prefix..enemy.name..postfix, 260, yoffset+y*15, 740, "left")
			
			local enemyCondition = ENEMY_HEALTH_CONDITIONS[0] -- healthy
			if enemy.hps < enemy.max_hps * 0.90 then enemyCondition = ENEMY_HEALTH_CONDITIONS[1] end	-- injured
			if enemy.hps < enemy.max_hps * 0.75 then enemyCondition = ENEMY_HEALTH_CONDITIONS[2] end	-- hurt
			if enemy.hps < enemy.max_hps * 0.55 then enemyCondition = ENEMY_HEALTH_CONDITIONS[3] end	-- badly hurt
			if enemy.hps < enemy.max_hps * 0.15 then enemyCondition = ENEMY_HEALTH_CONDITIONS[4] end	-- almost dead
			
			love.graphics.printf(enemyCondition, -110, yoffset+y*15, 740, "right")
			
			y = y + 1	
		end	
	
	end	

	-- draw characters
	
	renderer:drawCharacterList()

	if self.state == CombatStates.PLAYER_TURN or self.state == CombatStates.SELECT_TARGET then
		love.graphics.rectangle("line",261,136 + (self.turnCharacterIndex-1)*15,25,13)
	end

	if self.state == CombatStates.ENEMY_TURN then
		love.graphics.rectangle("line",261,41 + (self.turnEnemyIndex-1)*15,25,13)
	end
	
	if self.state == CombatStates.VICTORY then
		love.graphics.printf("-- VICTORY --", 380, 60, 740, "left")
	end

	renderer:drawMessageLog()
	
	self:drawCommandbar()

	renderer:finalize()

end

function CombatScreen:drawCommandbar()

	if self.state == CombatStates.INIT then
		love.graphics.printf("[A]ttack [F]lee", 10, 335, 640, "left")
		return
	end
	
	if self.state == CombatStates.PLAYER_TURN then
		local char = party.characters[self.turnCharacterIndex]
		
		if self.substate == SubStates.IDLE then
			local meleeStr = party:canAttackWithMelee(char) and "[A]ttack  " or ""
			local rangedStr = party:canAttackWithRanged(char) and "[S]hoot  " or ""
			local castStr = party:canCastSpell(char) and "[C]ast  " or ""
			love.graphics.printf(meleeStr..rangedStr..castStr.."[U]se  [D]efend  [M]ove  [E]xchange  [F]lee", 10, 335, 640, "left")
			return
		end
		
		if self.substate == SubStates.SELECT_ENEMY_MELEE_TARGET then
			love.graphics.printf("Select target [A-"..string.char(65+#self.enemies-1).."]: ", 10, 335, 640, "left")
			return
		end	

		if self.substate == SubStates.SELECT_ENEMY_RANGED_TARGET then
			love.graphics.printf("Select target [A-"..string.char(65+#self.enemies-1).."]: ", 10, 335, 640, "left")
			return
		end	
		
		if self.substate == SubStates.SELECT_ENEMY_SPELL_TARGET then
			love.graphics.printf("Select target [A-"..string.char(65+#self.enemies-1).."]: ", 10, 335, 640, "left")
			return
		end	
		
		if self.substate == SubStates.SELECT_PLAYER_SPELL_TARGET then
			love.graphics.printf("Select target [1-"..#party.characters.."]: ", 10, 335, 640, "left")
			return
		end		
		
		if self.substate == SubStates.EXCHANGE then
			love.graphics.printf("Exchange with [1-"..#party.characters.."]: ", 10, 335, 640, "left")
			return
		end		
		
	end

	if self.state == CombatStates.SELECT_TARGET then
		love.graphics.printf("Select target [A-"..string.char(65+#self.enemies-1).."]: ", 10, 335, 640, "left")
		return
	end
	
	if self.state == CombatStates.VICTORY then
		love.graphics.printf("Press [SPACE] to continue", 10, 335, 640, "left")
		return
	end

	if self.state == CombatStates.LOST_BATTLE then
		love.graphics.printf("Press [SPACE] to continue", 10, 335, 640, "left")
		return
	end
	
end

function CombatScreen:playerActed(cmd)

	local char = party.characters[self.turnCharacterIndex]

	if cmd == 'a' and party:canAttackWithMelee(char) then -- Attack with melee
		
		if #self.enemies > 1 then
			self.substate = SubStates.SELECT_ENEMY_MELEE_TARGET
			self:draw()
		else
			self:performPlayerAttack(1)
		end
		
		return
	end
	
	if cmd == 'u' and not party:isIncapacitated(char) then -- use item
		local num = party:getUseableItems(char)
		if #num == 0 then
			messages:add(char.name.." doesn't have any usable items.")
			self:draw()
			return
		else
			self.substate = SubStates.SELECT_ITEM
			screens.useitemscreen:show(self, char)
		end
		return
	end
			
	if cmd == 's' and party:canAttackWithRanged(char) then -- Attack with ranged weapon
		
		if #self.enemies > 1 then
			self.substate = SubStates.SELECT_ENEMY_RANGED_TARGET
			self:draw()
		else
			self:performPlayerAttack(1)
		end

		return
	end	

	if cmd == 'e' then -- Exchange
		self.substate = SubStates.EXCHANGE
		self:draw()
		return
	end	

	if cmd == 'm' then -- Move
		if char.row == FRONT_ROW then
			if party:moveToRear(self.turnCharacterIndex) then
				self:endCharacterTurn()
			end
		else
			if party:moveToFront(self.turnCharacterIndex) then
				self:endCharacterTurn()
			end
		end
		self:draw()
		return
	end	

	if cmd == 'd' then -- Defend
		messages:add(char.name.." defends.")
		char.defending = true
		char.acted = true
		self:endCharacterTurn()
		return
	end

	if cmd == 'c' and party:canCastSpell(char) then -- Cast spell
		if char.spellbook then
			self.substate = SubStates.SELECT_SPELL
			screens.spellbookscreen:show(self, char, true)
		end
		return 
	end
	
end

function CombatScreen:performPlayerAttack(targetIndex)

	local char = party.characters[self.turnCharacterIndex]
	local enemy = self.enemies[targetIndex]

	if not party:canTargetEnemy(char, enemy) then
		messages:add(char.name.." cannot target that enemy.")
		self:draw()
		return
	end

	local attackTypeStr = "attack"

	if party:canAttackWithRanged(char) then
		attackTypeStr = "shoot"
	end
	
	-- there is always a small chance that there will be a miss
	
	if math.random() > 0.75 then
		messages:add(char.name.." attempt to "..attackTypeStr.." "..enemy.name.." but miss.")
		char.acted = true
		self:endCharacterTurn()	
		return
	end


	local enemydef = enemy.def

	if enemy.defending == true then
		enemydef = enemydef * COMBAT_DEFEND_MULTIPLIER
	end
		
	-- calc damage

	local damage = 2 * math.pow(char.stats.atk, 2) / (char.stats.atk + enemydef)
	
	-- round the damage to avoid decimals
	
	damage = randomizeDamage(damage)

	-- display attack message

	local attackmessage = ""

	if damage < 1 then
		attackmessage = " "..attackTypeStr.."s "..enemy.name.." but fail to do any damage."
	else
		attackmessage = " "..attackTypeStr.."s "..enemy.name.." for "..damage.." damage."
	end
	
	enemy.hps = enemy.hps - damage

	if enemy.hps <= 0 then
		attackmessage = " "..attackTypeStr.."s "..enemy.name.." for "..damage.." damage and kills it."
		table.remove(self.enemies, targetIndex)
		self:updateEnemyRows()
	end

	messages:add(char.name..attackmessage)

	-- killed all enemies?

	if #self.enemies == 0 then
		self:victory()
		return
	end

	char.acted = true

	self:endCharacterTurn()

end

function CombatScreen:useItem(useableitem)

	local char = party.characters[self.turnCharacterIndex]
	local item = char.inventory[useableitem.original_index]
	local itemTemplate = itemtemplates:get(item.template)

	if party:useItem(char, itemTemplate) then
		item.stack = item.stack - 1
		if item.stack == 0 then
			table.remove(char.inventory, useableitem.original_index)
		end

		char.acted = true

		self:endCharacterTurn()
	
	else
		self.substate = SubStates.IDLE
		self:draw()
	end

end

function CombatScreen:endCharacterTurn()

	self.substate = SubStates.IDLE

	-- find next available character that can act this round

	if self:nextCharacter() then
		self:draw()
		return
	end

	-- player turn ended so we call tick()
	
	self.caller:tick()


	-- if all characters have acted this round then switch to enemy turn

	self:enemyBeginTurn()
		
end

function CombatScreen:nextCharacter()

	-- find next available character that can act this round

	for i = 1, #party.characters do
		if not party.characters[i].acted and playerCanAct(party.characters[i]) then
			self.turnCharacterIndex = i
			return party.characters[i]
		end
	end

	return nil

end

function CombatScreen:nextEnemy()

	-- find next available enemy that can act this round

	for i = 1, #self.enemies do
		if self.enemies[i].acted == false and enemyCanAct(self.enemies[i]) then
			self.turnEnemyIndex = i
			return self.enemies[i]
		end
	end

	return nil

end

function CombatScreen:victory()

	messages:add("You are victorious!")
	messages:add("Each alive character gain "..self.experienceGained.." experience points.")
	
	party:addExperience(self.experienceGained)
	
	self.state = CombatStates.VICTORY
	self.substate = SubStates.IDLE
	self:draw()

end

function CombatScreen:enemyAct()

	local enemy = self.enemies[self.turnEnemyIndex]

	enemy.acted = true
	
	-- first check if enemy should move to front row 

	local frontRow = getEnemiesInFrontRow(self.enemies)

	if #frontRow == 1 then
	
		if enemy.group == "melee" and enemy.row == BACK_ROW then
			enemy.row = FRONT_ROW
			messages:add(enemy.name.." moves to front row.")
			self.enemyActStart = os.clock()
			self:draw()
			return
		end
		
		if enemy.group == "caster" and enemy.row == BACK_ROW then
			local range = enemy.range and enemy.range or 1
			local spell = spelltemplates:get(enemy.spellbook[1])
			if range == 1 and enemy.mps < spell.mps_cost then
				enemy.row = FRONT_ROW
				messages:add(enemy.name.." moves to front row.")
				self.enemyActStart = os.clock()
				self:draw()
				return
			end
		end
		
	end		

	-- store targets in a table
	
	local targets = {}
	local castingfailed = false
	local attackMessage = ""
	
	-- is the acting enemy a spellcaster?

	if enemy.spellbook then
		
		-- if a enemy is a spellcaster there is a chance that it will decide to defend
		
		if math.random() > 0.5 then
			enemy.defending = true
			messages:add(enemy.name.." defends.")
			self:draw()
			self.enemyActStart = os.clock()		
			return
		end
		
		local spell = spelltemplates:get(enemy.spellbook[1])
		
		-- if has enough mana to cast spell
		
		if enemy.mps >= spell.mps_cost then
			enemy.mps = enemy.mps - spell.mps_cost
			if enemy.mps < 0 then enemy.mps = 0 end
			if spell.num_targets == 1 then
				local r = math.random(1, #party.characters)
				table.insert(targets, party.characters[r])
			else
				for i = 1, #party.characters do
					if party.characters[i].status ~= STATUS_DEAD then
						table.insert(targets, party.characters[i])
					end
				end
			end
			attackMessage = " casts \""..spell.name.."\" on "
		else
			
			-- fall back to melee
			
			castingfailed = true
		end
		
	end
	
	-- is the acting enemy a ranged attacker?
	
	if enemy.group == "ranged" then
		table.insert(targets, randomPartyCharacter())
		attackMessage = " shoots "
	end
	
	-- is the acting enemy a melee attacker?
	
	if enemy.group == "melee" or castingfailed then
		
		local range = enemy.range and enemy.range or 1
		
		if range == 2 then
			if enemy.row == FRONT_ROW then
				local r = math.random(1, #party.characters)
				table.insert(targets, party.characters[r])
			else
				local frontRow = party:getFrontRow()
				if #frontRow > 0 then
					local char = randomPartyCharacter(FRONT_ROW)
					if char then table.insert(targets, char) end
				end		
			end
		else
			if enemy.row == FRONT_ROW then
				local frontRow = party:getFrontRow()
				if #frontRow > 0 then
					local char = randomPartyCharacter(FRONT_ROW)
					if char then table.insert(targets, char) end
				end		
			end
		end

		attackMessage = " attacks "
	end
	
	for i = 1, #targets do
	
		-- there is always a small chance that the attack will miss
		
		if math.random() >= 0.75 then
			
			messages:add(enemy.name..attackMessage..targets[i].name.." but miss.")
			
		else

			-- calc damage

			local chardef = targets[i].stats.def

			if targets[i].defending == true then
				chardef = chardef * COMBAT_DEFEND_MULTIPLIER
			end
		
			local atk = spell and spell.modifiers.atk or targets[i].stats.atk
		
			local damage = 2 * math.pow(atk, 2) / (atk + chardef)

			-- round the damage to avoid decimals
			
			damage = randomizeDamage(damage)

			-- display attack message
			
			if damage < 1 then
				attackmessage = attackMessage..targets[i].name.." but fail to do any damage."
			else
				attackmessage = attackMessage..targets[i].name.." for "..damage.." damage."
			end
			
			targets[i].stats.hps = targets[i].stats.hps - damage

			messages:add(enemy.name..attackmessage)

			if targets[i].stats.hps <= 0 then
				targets[i].stats.hps = 0
				targets[i].status = STATUS_DEAD
				messages:add("-- "..targets[i].name.." has been killed --")
			end
		
		end

	end
	
	if #targets == 0 then
		enemy.defending = true
		messages:add(enemy.name.." defends.")
	end

	self:draw()
	self.enemyActStart = os.clock()

end

function CombatScreen:enemyBeginTurn()

	for i = 1, #self.enemies do
		self.enemies[i].acted = false
		self.enemies[i].defending = false
	end

	-- if all enemies have acted this round then switch to player turn

	local enemy = self:nextEnemy()
	
	if not enemy then
		self:playerBeginTurn()
		return
	end

	-- begin enemy turn

	self.state = CombatStates.BEFORE_ENEMY_TURN
	self.enemyRoundStart= os.clock()
	self:draw()
	
end

function CombatScreen:playerBeginTurn()

	for i = 1, #party.characters do
		party.characters[i].defending = false
		party.characters[i].acted = false
	end

	if not self:nextCharacter() then
		self:lostBattle()
		return
	end

	self.state = CombatStates.PLAYER_TURN
	self:draw()

end

function CombatScreen:lostBattle()

	messages:add("Your party of adventurers have been defeated!")
	self.state = CombatStates.LOST_BATTLE
	self:draw()

end

function CombatScreen:attemptToFlee()

	ACTIVESCREEN = nil
	self.showing = false
	self.caller:onCombatFled()

end

function CombatScreen:castSpellOnCharacter(characterIndex)

	local spell = self.currentSpell
	local caster = party.characters[self.turnCharacterIndex]

	if party:castSpell(caster, spell, characterIndex) then
		caster.acted = true
		self:endCharacterTurn()
	else
		self.substate = SubStates.IDLE
		self:draw()
	end
	
end

function CombatScreen:castSpellOnEnemy(enemyIndex)

	local char = party.characters[self.turnCharacterIndex]
	local targets = {}
	
	if enemyIndex then
	
		-- target single target enemy
	
		table.insert(targets, self.enemies[enemyIndex])

	else
	
		-- target all alive enemies
	
		for i = 1, #self.enemies do
			table.insert(targets, self.enemies[i])
		end
	
	end

	-- process the enemies in the targets table and cast spell on them

	for i = 1, #targets do
	
		local enemy = targets[i]
	
		-- damage type spell
	
		if self.currentSpell.modifiers.atk then

			local atk = self.currentSpell.modifiers.atk
			local enemydef = enemy.def

			-- add defensive bonus when defending

			if enemy.defending == true then
				enemydef = enemydef * COMBAT_DEFEND_MULTIPLIER
			end

			-- calc damage

			local damage = 2 * math.pow(atk, 2) / (atk + enemydef)
			
			-- round the damage to avoid decimals
			
			damage = randomizeDamage(damage)

			enemy.hps = enemy.hps - damage

			-- display attack message

			local attackmessage = ""

			if damage < 1 then
				attackmessage = " casts \""..self.currentSpell.name.."\" on "..enemy.name.." but fail to do any damage."
			else
				attackmessage = " casts \""..self.currentSpell.name.."\" on "..enemy.name.." doing "..damage.." damage."
			end
			
			-- was enemy killed?
			
			if enemy.hps <= 0 then
				messages:add(char.name.." casts \""..self.currentSpell.name.."\" on "..enemy.name.." doing "..damage.." damage and kills it.")
			else
				messages:add(char.name..attackmessage)
			end

		end
	
	end

	-- clean up dead enemies
	
	local num = #self.enemies
	local index = 1
	
	for i = 1, num do
		if self.enemies[index].hps <= 0 then
			table.remove(self.enemies, index)
		else
			index = index + 1
		end
	end

	-- killed all enemies?

	if #self.enemies == 0 then
		self:victory()
		return
	end	
		
	self:updateEnemyRows()

	char.stats.mps = char.stats.mps - self.currentSpell.mps_cost
	if char.stats.mps < 0 then char.stats.mps = 0 end

	char.acted = true

	self:endCharacterTurn()

end

function CombatScreen:updateEnemyRows()

	local frontRow = getEnemiesInFrontRow(self.enemies)
	
	-- if no enemies left in the front row then move all from back row to front
	
	if #frontRow == 0 then
		local backRow = getEnemiesInBackRow(self.enemies)
		for i = 1, #backRow do
			self.enemies[i].row = FRONT_ROW
		end
		return
	end

end

function CombatScreen:processKey(key)

	if self.showing == false then
		return
	end

    if key == 'pagedown' then
        messages:scrollUp()
		self:draw()
		return
    end
		
    if key == 'pageup' then
        messages:scrollDown()
		self:draw()
		return
    end
	
	if self.substate == SubStates.IDLE then
	
		if self.state == CombatStates.PLAYER_TURN then
			if key == 'f' or key == 'escape' then
				self:attemptToFlee()
				return
			end
		end
		
		if self.state == CombatStates.INIT then
		
			if key == 'a' then
				self.turnCharacterIndex = 1
				self.state = CombatStates.PLAYER_TURN
				self:draw()
				return
			end
		
			if key == 'r' or key == 'escape' then
				self:attemptToFlee()
				return
			end		
		
		end
		
		if self.state == CombatStates.PLAYER_TURN then
			if key == 'a' then
				self:playerActed(key)
				return
			end
			if key == 's' then
				self:playerActed(key)
				return
			end
			if key == 'u' then
				self:playerActed(key)
				return
			end
			if key == 'c' then
				self:playerActed(key)
				return
			end
			if key == 'm' then
				self:playerActed(key)
				return
			end
			if key == 'e' then
				self:playerActed(key)
				return
			end
			if key == 'd' then
				self:playerActed(key)
				return
			end
		end	
		
		if self.state == CombatStates.VICTORY then
			if key == 'space' then
				self.encounter.state = 2 -- dead
				globalvariables:add(self.encounter.id, "state", 2)
				ACTIVESCREEN = nil
				self.showing = false
				self.caller:onCombatEnded(self.encounter)
				return
			end
		end	
		
		if self.state == CombatStates.LOST_BATTLE then
			if key == 'space' then
				ACTIVESCREEN = nil
				self.showing = false
				self.caller:onCombatEnded(self.encounter)
				return
			end
		end			

	end
	
	if self.substate == SubStates.SELECT_PLAYER_SPELL_TARGET then

		if key == 'return' or key == 'escape' then
			self.substate = SubStates.IDLE
			self:draw()
			return
		end
			
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= #party.characters then
				self:castSpellOnCharacter(tonumber(key))
			end			
		end
		
	end
	
	if self.substate == SubStates.SELECT_ENEMY_MELEE_TARGET then
	
		if key == 'return' or key == 'escape' then
			self.substate = SubStates.IDLE
			self:draw()
			return
		end
		
		if string.byte(key) >= 97 and string.byte(key) <= 97+#self.enemies-1 then
			local targetIndex = string.byte(key)-96
			self:performPlayerAttack(targetIndex)
			return
		end			

	end		
	
	if self.substate == SubStates.SELECT_ENEMY_RANGED_TARGET then
	
		if key == 'return' or key == 'escape' then
			self.substate = SubStates.IDLE
			self:draw()
			return
		end
		
		if string.byte(key) >= 97 and string.byte(key) <= 97+#self.enemies-1 then
			local targetIndex = string.byte(key)-96
			self:performPlayerAttack(targetIndex)
			return
		end			

	end	
	
	if self.substate == SubStates.SELECT_ENEMY_SPELL_TARGET then
	
		if key == 'return' or key == 'escape' then
			self.substate = SubStates.IDLE
			self:draw()
			return
		end
		
		if string.byte(key) >= 97 and string.byte(key) <= 97+#self.enemies-1 then
			local targetIndex = string.byte(key)-96
			self:castSpellOnEnemy(targetIndex)
			return
		end			

	end		
	
	if self.substate == SubStates.EXCHANGE then
	
		if key == 'return' or key == 'escape' then
			self.substate = SubStates.IDLE
			self:draw()
			return
		end
		
		if tonumber(key) >= 1 and tonumber(key) <= #party.characters then
			party:exchange(self.turnCharacterIndex, tonumber(key))
			self.turnCharacterIndex = tonumber(key)
			self.substate = SubStates.IDLE
			party.characters[self.turnCharacterIndex].acted = true
			self:endCharacterTurn()
			return
		end			
	
	end			
	
end

-------------------------------------------------------------------------------------------------------------------------
-- Callback events
-------------------------------------------------------------------------------------------------------------------------

function CombatScreen:onScreenClosed()

	ACTIVESCREEN = self
	self.substate = SubStates.IDLE
	self:draw()

end

function CombatScreen:onSelectSpell(spell)

	ACTIVESCREEN = self

	self.currentSpell = spell

	-- is this a spell that can be cast on party members or enemies?

	if spell.target_type == "party" then

		-- check if caster has enough mana for this spell

		if party.characters[self.turnCharacterIndex].stats.mps < spell.mps_cost then
			messages:add(party.characters[self.turnCharacterIndex].name.." doesn't have enough magic points to cast this spell.")
			return false
		end

		if spell.affect_all and spell.affect_all == true then
			-- cast on entire party
			self:castSpellOnCharacter()
		else
			-- cast on single party member
			self.substate = SubStates.SELECT_PLAYER_SPELL_TARGET
			self:draw()
		end
	else
	
		-- check if caster has enough mana for this spell

		if party.characters[self.turnCharacterIndex].stats.mps < spell.mps_cost then
			messages:add(party.characters[self.turnCharacterIndex].name.." doesn't have enough magic points to cast this spell.")
			return false
		end
	
		if spell.affect_all and spell.affect_all == true then
			-- cast on all enemies
			self:castSpellOnEnemy()
		else
			-- cast on single enemy
			if #self.enemies == 1 then
				self:castSpellOnEnemy(1)
			else
				self.substate = SubStates.SELECT_ENEMY_SPELL_TARGET
				self:draw()
			end
		end
		
	end

end

function CombatScreen:onSelectItem(useableitem)

	ACTIVESCREEN = self

	self:useItem(useableitem)
	
end

-------------------------------------------------------------------------------------------------------------------------

return CombatScreen
