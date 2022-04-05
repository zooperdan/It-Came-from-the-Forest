local ChestScreen = class('ChestScreen')

local ChestStates = {
	IS_IDLE = 0,
	IS_SOLVE = 1
}

function ChestScreen:initialize()
	
end

function ChestScreen:init(caller)

	self.caller = caller
	self.canvas = caller.canvas
	
end

function ChestScreen:show(chest)

	ACTIVESCREEN = self
	
	self.chest = chest
	
	local msg = "There is an old wooden chest here."
		
	if chest.state == 2 then
		msg = "There is an old wooden chest here which appears to be locked."
	end	

	if chest.state == 3 then
		msg = "There is an old wooden chest here which appears to be protected by some puzzle mechanism."
	end	
	
	if chest.state == 4 then
		msg = "The chest is empty."
	end		

	messages:add(msg)

	self.showing = true
	
	self:draw()
	
end

function ChestScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	love.graphics.draw(assets.images["screen_treasure"], 11, 11)

	renderer:drawStatusOverview()
	renderer:drawCharacterList()

	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function ChestScreen:drawCommandbar()

	if self.chest.state == 1 then
		love.graphics.printf("[O]pen [B]ack", 10, 335, 640, "left")
	end	

	if self.chest.state == 2 then
		love.graphics.printf("[U]nlock  [P]ick lock  [B]ack", 10, 335, 640, "left")
	end	

	if self.chest.state == 3 then
		love.graphics.printf("[S]olve  [B]ack", 10, 335, 640, "left")
	end	
	
	if self.chest.state == 4 then
		love.graphics.printf("[B]ack", 10, 335, 640, "left")
	end	
	
end

function ChestScreen:processKey(key)

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
	
	if self.chest.state == 1 or self.chest.state == 4 then
		if key == 'b' then
			ACTIVESCREEN = nil
			self.showing = false
			self.caller:onScreenClosed()
			return
		end		
	end	

	if self.chest.state == 2 then
		
		if key == 'u' then -- unlock
			messages:add("You don't have the key that unlocks this chest.")
			self:draw()
			return
		end
		
		if key == 'p' then -- pick lock
			messages:add("You don't have any lockpicks.")
			self:draw()
			return
		end
		
		if key == 'b' then
			ACTIVESCREEN = nil
			self.showing = false
			self.caller:onScreenClosed()
			return
		end		
		
	end

	if self.chest.state == 3 then
		
		if key == 's' then -- solve
			ACTIVESCREEN = nil
			self.showing = false
			self.caller:onScreenClosed()
			return
		end
		
		if key == 'b' or key == 'escape' then
			ACTIVESCREEN = nil
			self.showing = false
			self.caller:onScreenClosed()
			return
		end		
		
	end
	
end

return ChestScreen
