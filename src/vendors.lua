local Vendors = class('Vendors')

function Vendors:initialize()
	
	self.vendor = {}
	
	self.vendor["alchemist"] = {
		id = "alchemist",
		name = "Akvorn Covenfury",
		imageid = "npc-sorcerer-2",
		text = "Welcome to my humble alchemy shop.\n\nWould you like to buy some potions?",
		stock = {"healing-potion", "mana-potion"},
		prices = {100, 100},
	}
	
	self.vendor["magicshop"] = {
		id = "magicshop",
		name = "Neshen Bhanne",
		imageid = "npc-sorcerer-3",
		text = "Welcome traveller.\n\nCould I interest you in some spells?",
		stock = {"lesser-heal", "full-heal", "firebolt", "fireball", "town-portal"},
		prices = {250, 750, 250, 750, 1000},
	}	
	
end	

return Vendors
