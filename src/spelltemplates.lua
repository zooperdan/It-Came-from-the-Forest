local SpellTemplates = class('SpellTemplates')

function SpellTemplates:initialize()

	self.templates = {}

	local template = {
		name = "Minor heal",
		id = "minor_heal",
		target_type = "party",
		group = "healing",
		num_targets = 1,
		mps_cost = 5,
		modifiers = {
			["hps"] = 25
		}
	}
	
	self.templates[template.id] = template
	
	local template = {
		name = "Major heal",
		id = "major_heal",
		target_type = "party",
		group = "healing",
		num_targets = 1,
		mps_cost = 20,
		modifiers = {
			["hps"] = 50
		}
	}
	
	self.templates[template.id] = template	
	
	local template = {
		name = "Minor party heal",
		id = "minor_party_heal",
		target_type = "party",
		group = "healing",
		affect_all = true,
		num_targets = 4,
		mps_cost = 5,
		modifiers = {
			["hps"] = 25
		}
	}
	
	self.templates[template.id] = template		
	
	local template = {
		name = "Magic missile",
		id = "magic_missile",
		group = "damage",
		target_type = "enemy",
		num_targets = 1,
		mps_cost = 5,
		modifiers = {
			["atk"] = 6
		}
	}
	
	self.templates[template.id] = template	

	local template = {
		name = "Fireball",
		id = "fireball",
		group = "damage",
		target_type = "enemy",
		affect_all = true,
		mps_cost = 15,
		modifiers = {
			["atk"] = 10
		}
	}
	
	self.templates[template.id] = template	
	
end

function SpellTemplates:get(id)

	return table.shallow_copy(self.templates[id])
		
end

function SpellTemplates:dump()

	print(inspect(self.templates))
		
end

return SpellTemplates