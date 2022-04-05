local Party = class('Party')

classes = {
	["Warrior"] = {
		basestats =  { ["str"] = 3,	["vit"] = 1, ["agi"] = 1, ["int"] = 1, ["wil"] = 1,	["max_hps"] = 0, ["max_mps"] = 0, ["atk"] = 0, ["def"] = 0 },
		hps_mod = {	str = 2, vit = 2, agi = 0, int = 0, wil = 0	},
		mps_mod = {	str = 0, vit = 0, agi = 0, int = -1, wil = -1 }
	},
	["Rogue"] = {
		basestats =  { ["str"] = 1,	["vit"] = 1, ["agi"] = 3, ["int"] = 1, ["wil"] = 1, ["max_hps"] = 0, ["max_mps"] = 0, ["atk"] = 0, ["def"] = 0 },
		hps_mod = {	str = 1, vit = 1, agi = 0, int = 0,	wil = 0	},
		mps_mod = {	str = 0, vit = 0, agi = 0, int = -1, wil = -1 }
	},
	["Cleric"] = {
		basestats =  { ["str"] = 1,	["vit"] = 1, ["agi"] = 1, ["int"] = 3, ["wil"] = 1,	["max_hps"] = 0, ["max_mps"] = 0, ["atk"] = 0, ["def"] = 0 },
		hps_mod = {	str = 0, vit = 0, agi = 0, int = 0,	wil = 0	},
		mps_mod = {	str = 0, vit = 0, agi = 0, int = 0,	wil = 0	}
	},
	["Wizard"] = {
		basestats =  { ["str"] = 1,	["vit"] = 1, ["agi"] = 1, ["int"] = 3, ["wil"] = 1,	["max_hps"] = 0, ["max_mps"] = 0, ["atk"] = 0, ["def"] = 0 },
		hps_mod = {	str = 0, vit = 0, agi = 0, int = 0,	wil = 0	},
		mps_mod = {	str = 0, vit = 0, agi = 0, int = 0,	wil = 0	}
	}	
}

function Party:initialize()

	self.direction = 0
	self.x = 1
	self.y = 1
	self.gold = 0
	self.food = 0
	
	self.characters =  {}
	
	local character = {
		name = "Boff Grankert",
		level = 1,
		gender = "Male",
		classtype = "Warrior",
		experience = 0,
		status = STATUS_ALIVE,
		row = FRONT_ROW,
		inventory = {
			{
				template = "short_sword",
				equipped = 1
			},
			{
				template = "small_wooden_buckler",
				equipped = 1
			},
			{
				template = "potion_of_minor_heal",
				stack = 5
			},
			{
				template = "potion_of_major_heal",
				stack = 2
			},
			{
				template = "potion_of_minor_magic",
				stack = 1
			},
			
			{
				template = "rune_of_godly_strength"
			},
			{
				template = "stale_bread",
				stack = 6
			},	
			{
				template = "ring_of_strength",
				equipped = 0
			},	
			{
				template = "girdle_of_giants",
				equipped = 0
			},	
			{
				template = "long_sword",
				equipped = 0
			},	
			{
				template = "emerald_sword_of_thyx",
				equipped = 0
			},	
			{
				template = "ring_of_the_bear",
				equipped = 0
			},
			{
				template = "ring_of_strength",
				equipped = 0
			},
			{
				template = "short_sword",
			}
			
		},
		basestats = {}
	}

	table.insert(self.characters, character)

	local character = {
		name = "Geledric",
		level = 1,
		gender = "Male",
		classtype = "Rogue",
		experience = 0,
		status = STATUS_ALIVE,
		row = BACK_ROW,
		inventory = {
			{ template = "short_bow", equipped = 1 },
			{ template = "rusty_dagger", equipped = 0 },
			{ template = "small_wooden_buckler", equipped = 1 },
			{ template = "ring_of_strength", equipped = 0 },
			{ template = "potion_of_minor_heal", stack = 2 },
			{ template = "red_apple", stack = 4 }
		},
		basestats = {}
	}

	table.insert(self.characters, character)

	local character = {
		name = "Kendara",
		level = 1,
		gender = "Female",
		classtype = "Cleric",
		experience = 0,
		status = STATUS_ALIVE,
		row = BACK_ROW,
		inventory = {
			{ template = "staff", equipped = 1 },
			{ template = "rusty_dagger", equipped = 0 },
			{ template = "small_wooden_buckler", equipped = 1 },
			{ template = "potion_of_minor_magic", stack = 4 },
			{ template = "potion_of_major_magic", stack = 1 }
		},
		basestats = {},
		spellbook = { "magic_missile", "minor_heal", "major_heal", "minor_party_heal" }
	}

	table.insert(self.characters, character)

	local character = {
		name = "Linariumis Nix",
		level = 1,
		gender = "Male",
		classtype = "Wizard",
		experience = 0,
		status = STATUS_ALIVE,
		row = BACK_ROW,
		inventory = {
			{ template = "rusty_dagger", equipped = 1 },
			{ template = "small_wooden_buckler", equipped = 1 },
			{ template = "red_apple", stack = 2 },
			{ template = "potion_of_minor_magic", stack = 2 }
		},
		basestats = {},
		spellbook = { "magic_missile", "fireball" }
	}

	table.insert(self.characters, character)

	self:reorderCharacters()

end

function Party:getFrontRow()

	local row = {}

	for i = 1, #self.characters do
		if self.characters[i].row == FRONT_ROW then
			table.insert(row, i)
		end
	end

	return row;

end

function Party:getBackRow()

	local row = {}

	for i = 1, #self.characters do
		if self.characters[i].row == BACK_ROW then
			table.insert(row, i)
		end
	end

	return row;

end

function Party:addGold(amount)

	party.gold = party.gold + amount

end

function Party:isIncapacitated(char)

	if char.status == STATUS_DEAD then return true end

	return false

end

function Party:canCast(char)

	if char.classtype == "Warrior" then return false end
	if char.classtype == "Rogue" then return false end

	return true

end

function Party:restUp()

	for i = 1, #self.characters do

		local char = self.characters[i]
		
		char.stats.hps = char.stats.max_hps
		char.stats.mps = char.stats.max_mps

	end

end

function Party:updateStats()

	self.food = 0

	for i = 1, #self.characters do
	
		local char = self.characters[i]
		
		-- apply base stats for the character's class. make backup of hps and mps since they are not calculated
		
		local hps = (char.stats and char.stats.hps) and char.stats.hps or 0
		local mps = (char.stats and char.stats.mps) and char.stats.mps or 0
		
		char.stats = table.shallow_copy(classes[char.classtype].basestats)
		
		char.stats.hps = hps
		char.stats.mps = mps
		
		-- apply item modifiers
		
		for j = 1, #char.inventory do
			local item = itemtemplates:get(char.inventory[j].template)
			if char.inventory[j].equipped == 1 then
				char.stats.atk = char.stats.atk + (item.modifiers.atk and item.modifiers.atk or 0)
				char.stats.def = char.stats.def + (item.modifiers.def and item.modifiers.def or 0)

				char.stats.str = char.stats.str + (item.modifiers.str and item.modifiers.str or 0)
				char.stats.vit = char.stats.vit + (item.modifiers.vit and item.modifiers.vit or 0)
				char.stats.agi = char.stats.agi + (item.modifiers.agi and item.modifiers.agi or 0)
				char.stats.int = char.stats.int + (item.modifiers.int and item.modifiers.int or 0)
				char.stats.wil = char.stats.wil + (item.modifiers.wil and item.modifiers.wil or 0)
			end
			
			-- check if food and add to party food counter
			if item.itemtype == "food" then
				party.food = party.food + char.inventory[j].stack
			end
		end
		
		-- apply calculated values

		if char.classtype == "Warrior" then
			char.stats.atk = char.stats.atk + (char.stats.str * 1.25) + (char.stats.agi / 4)
		elseif char.classtype == "Rogue" then
			char.stats.atk = char.stats.atk + (char.stats.str / 4) + (char.stats.agi / 2)
		else
			char.stats.atk = char.stats.atk + (char.stats.str / 6) + (char.stats.agi / 4)
		end

		char.stats.def = char.stats.def + char.stats.agi + (char.stats.vit / 2)

		char.stats.max_hps = char.stats.max_hps + ((char.stats.vit+classes[char.classtype].hps_mod.vit) * 5) + ((char.stats.str+classes[char.classtype].hps_mod.str)*2)
		char.stats.max_mps = char.stats.max_mps + ((char.stats.int+classes[char.classtype].mps_mod.int) * 5) + ((char.stats.wil+classes[char.classtype].mps_mod.wil)*2)

	end

end

function Party:useItem(char, itemTemplate)

	-- check if the item has been identified

	if itemTemplate.flags and itemTemplate.flags == UNIDENTIFIED then
		messages:add("The item must be identified first.")
		return false
	end

	-- check if the item is of consumable type
	
	if not itemtemplates:isConsumable(itemTemplate) then
		messages:add("That item cannot be used this way.")
		return false
	end

	-- check if hps is already full
	
	if itemTemplate.itemtype == "health_potion" then
		if char.stats["hps"] == char.stats["max_hps"] then
			messages:add(char.name .. " already has full health.")
			return false
		else
			messages:add(char.name .. " quaffs the potion and feel much better.")
		end
	end	
	
	-- check if mps is already full

	if itemTemplate.itemtype == "magic_potion" then
	
		if char.stats["mps"] == char.stats["max_mps"] then
			messages:add(char.name .. " already has full mana.")
			return false
		else
			messages:add(char.name .. " quaffs the potion and feels the magic surging through the body.")
		end
		
	end
	
	-- apply modifier
	
	if itemTemplate.modifiers then
		for key, value in next, itemTemplate.modifiers do
			char.stats[key] = char.stats[key] + value
		end
	end

	-- clamp values
	
	if char.stats["hps"] > char.stats["max_hps"] then
		char.stats["hps"] = char.stats["max_hps"]
	end		
	
	if char.stats["mps"] > char.stats["max_mps"] then
		char.stats["mps"] = char.stats["max_mps"]
	end
	
	return true
	
end

function Party:moveToFront(charIndex)

	if self.characters[charIndex].row == FRONT_ROW then
		messages:add(self.characters[charIndex].name.." is already positioned at the front.")
		return false
	end

	self.characters[charIndex].row = FRONT_ROW
	self.characters[charIndex].acted = true
	messages:add(self.characters[charIndex].name.." moves to the front.")
	self:reorderCharacters()

	return true

end

function Party:moveToRear(charIndex)

	if self.characters[charIndex].row == BACK_ROW then
		messages:add(self.characters[charIndex].name.." is already positioned at the rear.")
		return false
	end

	local row = self:getFrontRow()

	if #row > 1 then
		self.characters[charIndex].row = BACK_ROW
		self.characters[charIndex].acted = true
		messages:add(self.characters[charIndex].name.." moves to the rear.")
		self:reorderCharacters()
		return true
	else
		messages:add("There must be at least one character in front row.")
		return false
	end
	
end

function Party:reorderCharacters()

	local backupChars = table.shallow_copy(self.characters)

	self.characters = {}
	
	for i = 1, #backupChars do
		if backupChars[i].row == FRONT_ROW then
			table.insert(self.characters, backupChars[i])
		end
	end

	for i = 1, #backupChars do
		if backupChars[i].row == BACK_ROW then
			table.insert(self.characters, backupChars[i])
		end
	end

end

function Party:exchange(sourceIndex, targetIndex)

	local sourceChar = table.shallow_copy(self.characters[sourceIndex])
	local targetChar = table.shallow_copy(self.characters[targetIndex])

	if sourceIndex == targetIndex then
		local genderStr = "himself"
		if sourceChar.gender == "Female" then genderStr = "herself" end
		messages:add(sourceChar.name.." exchange places with "..genderStr.."...")
		return
	end

	local sourceRow = sourceChar.row
	local targetRow = targetChar.row

	messages:add(sourceChar.name.." exchange places with "..targetChar.name..".")

	self.characters[sourceIndex] = targetChar
	self.characters[sourceIndex].row = sourceRow
	self.characters[targetIndex] = sourceChar
	self.characters[targetIndex].row = targetRow

end

function Party:canCastSpell(char)

	if char.spellbook then
		return true
	else
		return false
	end

end

function Party:weaponRange(char)

	for i = 1, #char.inventory do

		local item = itemtemplates:get(char.inventory[i].template)
		
		if item.slot == "weapon" and item.itemtype == "melee" and char.inventory[i].equipped == 1 then
			return item.range and item.range or 1
		end
		
	end

	return 1

end

function Party:castSpell(caster, spell, targetIndex)

	local targets = {}

	if targetIndex then
		table.insert(targets, party.characters[targetIndex])
	else
		for i = 1, #party.characters do
			table.insert(targets, party.characters[i])
		end
	end

	local failedNum = 0

	for i = 1, #targets do

		local target = targets[i]
	
		-- check if target character is in a valid state for this spell

		if target.status ~= STATUS_ALIVE then
			messages:add("This spell don't work on dead people.")
			failedNum = failedNum + 1
			break
		end

		-- process and effectuate the spell

		local spellcast = false
		local msg = ""
		
		if spell.modifiers.hps then
			
			-- healing spell
			
			if target.stats.hps < target.stats.max_hps then
				target.stats.hps = target.stats.hps + spell.modifiers.hps
				if target.stats.hps > target.stats.max_hps then target.stats.hps = target.stats.max_hps end
				msg = caster.name.." casts \""..spell.name.."\" on "..target.name.."."
				spellcast = true
			else
				msg = target.name.." already have full health."
				failedNum = failedNum + 1
			end
			
		end
		
		if spellcast then
			caster.stats.mps = caster.stats.mps - spell.mps_cost
			if caster.stats.mps < 0 then caster.stats.mps = 0 end
		end
		
		-- display casting message

		messages:add(msg)

	end

	return #targets ~= failedNum

end

function Party:canAttackWithMelee(char, enemy)

	for i = 1, #char.inventory do
		
		local item = itemtemplates:get(char.inventory[i].template)
		
		if item.slot == "weapon" and item.itemtype == "melee" and char.inventory[i].equipped == 1 then
			local range = item.range and item.range or 1
			if range == 1 and char.row == BACK_ROW then return false end
			return true
		end
		
	end

	return false

end

function Party:canAttackWithRanged(char)

	for i = 1, #char.inventory do
		local item = itemtemplates:get(char.inventory[i].template)
		if item.slot == "weapon" and item.itemtype == "ranged" and char.inventory[i].equipped == 1 then return true end
	end

	return false

end

function Party:canTargetEnemy(char, enemy)

	for i = 1, #char.inventory do
		
		local item = itemtemplates:get(char.inventory[i].template)
		
		if item.slot == "weapon" and item.itemtype == "melee" and char.inventory[i].equipped == 1 then
			
			local range = item.range and item.range or 1
			
			if range == 2 then
				if char.row == BACK_ROW and enemy.row == BACK_ROW then return false end
				return true
			else
				if char.row == FRONT_ROW and enemy.row == FRONT_ROW then return true end
			end
			
		end
		
		if item.slot == "weapon" and item.itemtype == "ranged" and char.inventory[i].equipped == 1 then
			return true
		end		
		
	end
	
	return false

end

function Party:defeated()

	local numdead = 0

	for i = 1, #self.characters do
		if self.characters[i].status == STATUS_DEAD then
			numdead = numdead + 1
		end
	end
	
	return (numdead == #self.characters)

end

function Party:getUseableItems(char)

	local result = {}
	
	for i = 1, #char.inventory do
		local item = itemtemplates:get(char.inventory[i].template)
		if itemtemplates:isConsumable(item) then
			table.insert(result, { item = char.inventory[i], original_index = i })
		end
	end
	
	return result

end

function Party:addExperience(value)

	for i = 1, #self.characters do
		if self.characters[i].status ~= STATUS_DEAD then
			self.characters[i].experience = self.characters[i].experience + value
		end
	end
	
end

return Party