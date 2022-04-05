local ItemTemplates = class('ItemTemplates')

function ItemTemplates:initialize()

	self.templates = {}

	local template = {
		itemtype = "melee",
		id = "short_sword",
		name = "Short sword",
		slot = "weapon",
		value = 10,
		description = "It's short and it's a sword. It's a short sword.",
		modifiers = {
			["atk"] = 2
		}
	}
	
	self.templates[template.id] = template
	
	local template = {
		itemtype = "melee",
		id = "staff",
		name = "Staff",
		slot = "weapon",
		range = 2,
		value = 30,
		modifiers = {
			["atk"] = 4
		}
	}
	
	self.templates[template.id] = template
	
	local template = {
		itemtype = "melee",
		id = "long_sword",
		name = "Long sword",
		slot = "weapon",
		value = 30,
		modifiers = {
			["atk"] = 4
		}
	}
	
	self.templates[template.id] = template
	
	local template = {
		itemtype = "ranged",
		id = "short_bow",
		name = "Short bow",
		slot = "weapon",
		value = 30,
		modifiers = {
			["atk"] = 4
		}
	}
	
	self.templates[template.id] = template
	
	local template = {
		itemtype = "ranged",
		id = "sling",
		name = "Sling",
		slot = "weapon",
		value = 12,
		modifiers = {
			["atk"] = 2
		}
	}
	
	self.templates[template.id] = template	
	
	local template = {
		itemtype = "melee",
		id = "rusty_dagger",
		name = "Rusty dagger",
		slot = "weapon",
		value = 5,
		modifiers = {
			["atk"] = 2
		}
	}
	
	self.templates[template.id] = template
	
	local template = {
		itemtype = "melee",
		id = "emerald_sword_of_thyx",
		name = "Emerald sword of Thyx",
		unidentifiedname = "Sword",
		slot = "weapon",
		value = 200,
		description = "This is a sword of legends and a truly remarkable piece of craftmanship with an emerald encrusted hilt.",
		flags = UNIDENTIFIED,
		modifiers = {
			["atk"] = 10
		}
	}
	
	self.templates[template.id] = template
	
	local template = {
		itemtype = "armor",
		id = "small_wooden_buckler",
		name = "Small wooden buckler",
		slot = "shield",
		value = 10,
		modifiers = {
			["def"] = 1
		}
	}
	
	self.templates[template.id] = template

	local template = {
		itemtype = "armor",
		id = "leather_boots",
		name = "Leather boots",
		slot = "feet",
		value = 10,
		modifiers = {
			["def"] = 1
		}		
	}
	
	self.templates[template.id] = template

	local template = {
		itemtype = "armor",
		id = "metal_helmet",
		name = "Metal helmet",
		slot = "head",
		value = 10,
		modifiers = {
			["def"] = 1
		}		
	}
	
	self.templates[template.id] = template

	local template = {
		itemtype = "armor",
		id = "girdle_of_giants",
		name = "Girdle of giants",
		slot = "waist",
		value = 10,
		modifiers = {
			["str"] = 1
		}		
	}
	
	self.templates[template.id] = template
	
	local template = {
		itemtype = "food",
		id = "stale_bread",
		name = "Stale bread",
		stackable = 1,
		slot = "",
		value = 5,
		description = "It's a stale loaf of bread with specks of mold.",
	}
	
	self.templates[template.id] = template	
	
	local template = {
		itemtype = "food",
		id = "red_apple",
		name = "Red apple",
		stackable = 1,
		slot = "",
		value = 5,
		description = "It's a red and juicy apple.",
	}
	
	self.templates[template.id] = template		
	
	local template = {
		itemtype = "jewelry",
		id = "ring_of_strength",
		name = "Ring of strength",
		slot = "finger",
		value = 50,
		modifiers = {
			["str"] = 1
		}		
	}
	
	self.templates[template.id] = template		

	local template = {
		itemtype = "jewelry",
		id = "ring_of_the_bear",
		name = "Ring of the bear",
		slot = "finger",
		value = 50,
		modifiers = {
			["vit"] = 1
		}		
	}
	
	self.templates[template.id] = template	
	
	local template = {
		itemtype = "health_potion",
		id = "potion_of_minor_heal",
		name = "Potion of minor healing",
		stackable = 1,
		value = 25,
		modifiers = {
			["hps"] = 25
		}
	}
	
	self.templates[template.id] = template	

	local template = {
		itemtype = "health_potion",
		id = "potion_of_major_heal",
		name = "Potion of major healing",
		stackable = 1,
		value = 50,
		modifiers = {
			["hps"] = 50
		}
	}
	
	self.templates[template.id] = template	
	
	local template = {
		itemtype = "magic_potion",
		id = "potion_of_minor_magic",
		name = "Potion of minor magic",
		stackable = 1,
		value = 25,
		modifiers = {
			["mps"] = 25
		}
	}
	
	self.templates[template.id] = template	

	local template = {
		itemtype = "magic_potion",
		id = "potion_of_major_magic",
		name = "Potion of major magic",
		stackable = 1,
		value = 50,
		modifiers = {
			["mps"] = 50
		}
	}
		
	self.templates[template.id] = template		
	
	local template = {
		itemtype = "rune",
		id = "rune_of_godly_strength",
		name = "Rune of godly strength",
		unidentifiedname = "Rune",
		flags = UNIDENTIFIED,
		value = 150,
		modifiers = {
			["str"] = 5
		}
	}
		
	self.templates[template.id] = template		
	
end


function ItemTemplates:isConsumable(template)

	if template.itemtype == "health_potion" then return true end
	if template.itemtype == "magic_potion" then return true end
	if template.itemtype == "rune" then return true end

	return false

end


function ItemTemplates:get(id)

	return table.shallow_copy(self.templates[id])
		
end

return ItemTemplates