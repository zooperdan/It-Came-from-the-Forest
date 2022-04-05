local Party = class('Party')

function Party:initialize()

	self.direction = 0
	self.x = 1
	self.y = 1
	self.gold = 0
	self.food = 0

end

return Party