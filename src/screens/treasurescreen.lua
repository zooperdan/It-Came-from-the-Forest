local TreasureScreen = class('TreasureScreen')

function TreasureScreen:initialize()
	
end

function TreasureScreen:init(caller)
	self.caller = caller
	self.canvas = caller.canvas
end

function TreasureScreen:show(encounter)

	ACTIVESCREEN = self

	self.encounter = encounter

	messages:add("You search through the remains and find some treasure!")

	self.showing = true
	self:draw()

end

function TreasureScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	-- screen
	
	love.graphics.draw(assets.images["screen_treasure"], 11, 11)

	-- interface

	love.graphics.printf("Treasure!", 260, 8, 640, "left")

	-- draw items
	
	local index = 1
	local yoffset = 40
	local y = 0
	for i = 1, #self.encounter.loot do
		local item = itemtemplates:get(self.encounter.loot[i])
		love.graphics.printf("["..index.."] "..item.name, 260, yoffset + y, 640, "left")
		y = y + 15
		index = index + 1
	end

	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function TreasureScreen:drawCommandbar()

	love.graphics.printf("[T]ake  Take [a]ll  [B]ack", 10, 335, 640, "left")
	
end

function TreasureScreen:processKey(key)

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
	
	if key == 'b' or key == 'escape' then
		ACTIVESCREEN = nil
		self.showing = false
		self.caller:onScreenClosed()
	end	

end

return TreasureScreen
