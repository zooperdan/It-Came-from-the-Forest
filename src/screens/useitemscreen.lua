local UseItemScreen = class('UseItemScreen')

function UseItemScreen:initialize()
	
end

function UseItemScreen:init(caller)
end

function UseItemScreen:show(caller, char)

	ACTIVESCREEN = self

	self.caller = caller
	self.canvas = caller.canvas

	self.currentCharacter = char
	self.items = party:getUseableItems(char)
	self.showing = true
	self:draw()

end

function UseItemScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	-- screen
	
	love.graphics.draw(assets.images["screen_inventory"], 11, 11)

	-- interface

	love.graphics.printf("Useable items for "..self.currentCharacter.name, 260, 8, 640, "left")

	-- draw spells

	love.graphics.printf("[#]", 260, 35, 640, "left")
	love.graphics.printf("Item", 296, 35, 640, "left")
	
	local index = 1
	local yoffset = 55
	local y = 0
	
	for i = 1, #self.items do
		
		local item = itemtemplates:get(self.items[i].item.template)
		
		if itemtemplates:isConsumable(item) then
		
			if self.items[i].item.stack and self.items[i].item.stack > 1 then
				love.graphics.printf("["..index.."] "..item.name.." ("..self.items[i].item.stack..")", 260, yoffset + y, 640, "left")
			else
				if item.flags and item.flags == UNIDENTIFIED then
					love.graphics.printf("["..index.."] ("..item.unidentifiedname..")", 260, yoffset + y, 640, "left")
				else
					love.graphics.printf("["..index.."] "..item.name, 260, yoffset + y, 640, "left")
				end
			end
			y = y + 15
			index = index + 1
		end

	end
	
	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function UseItemScreen:drawCommandbar()

	love.graphics.printf("Choose item [1-"..#self.items.."]:", 10, 335, 640, "left")
	
end

function UseItemScreen:useItem(index)

	self.showing = false
	self.caller:onSelectItem(self.items[index])

end
function UseItemScreen:processKey(key)

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
	
	if tonumber(key) then
		if tonumber(key) >= 1 and tonumber(key) <= #self.items then
			self:useItem(tonumber(key))
			return
		end			
	end

	if key == 'return' or key == 'escape' then
		ACTIVESCREEN = nil
		self.showing = false
		self.caller:onScreenClosed()
	end	

end

return UseItemScreen
