local CampScreen = class('CampScreen')

local States = {
	IDLE = 0,
	ALTER_WHO = 1,
	ALTER_WHAT = 2,
	ALTER_ROW = 3,
	EXCHANGE = 4,
	EXCHANGE_WITH = 5,
	REST_UNTIL = 6,
	RESTING = 7,
	SAVING = 8,
}

function CampScreen:initialize()
	
end

function CampScreen:init(caller)
	
	self.caller = caller
	self.canvas = caller.canvas
	
end

function CampScreen:show()

	ACTIVESCREEN = self

	self.state = States.IDLE

	messages:add("You sit down to rest your tired bones.");
	self.showing = true
	self:draw();
	
end

function CampScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	love.graphics.draw(assets.images["screen_campfire"], 11, 11)

	renderer:drawStatusOverview()
	renderer:drawCharacterList()

	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function CampScreen:drawCommandbar()

	if self.state == States.IDLE then
		love.graphics.printf("[R]est  [S]ave  [L]oad  [A]lter  [E]xchange  [B]ack", 10, 335, 640, "left")
	elseif self.state == States.ALTER_WHO then
		love.graphics.printf("Alter character: [1-"..#party.characters.."]:", 10, 335, 640, "left")
	elseif self.state == States.ALTER_WHAT then
		love.graphics.printf("Alter: [N]ame  [P]osition", 10, 335, 640, "left")
	elseif self.state == States.ALTER_ROW then
		love.graphics.printf("Move "..party.characters[self.currentCharacterIndex].name.." to: [F]ront  [R]ear", 10, 335, 640, "left")
	elseif self.state == States.EXCHANGE then
		love.graphics.printf("Select character [1-"..#party.characters.."]:", 10, 335, 640, "left")
	elseif self.state == States.EXCHANGE_WITH then
		love.graphics.printf("Exchange with [1-"..#party.characters.."]:", 10, 335, 640, "left")
	elseif self.state == States.REST_UNTIL then
		love.graphics.printf("Rest until: [H]ealed  [M]orning", 10, 335, 640, "left")
	elseif self.state == States.SAVING then
		love.graphics.printf("Save to: [1*]  [2*]  [3]  [4]  [5]  [6]", 10, 335, 640, "left")
	end
	
end

function CampScreen:processKey(key)

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
	
	if self.state == States.IDLE then
	
		if key == 'r' then
			self.state = States.REST_UNTIL
			self:draw()
			return
		end

		if key == 'l' then
			--self:load()
			return
		end

		if key == 's' then
			self.state = States.SAVING
			messages:add("Saving game...")
			self:draw();
			return
		end
		
		if key == 'a' then
			if #party.characters == 1 then
				self.currentCharacterIndex = 1
				self.state = States.ALTER_WHAT
				self:draw()
			else
				self.state = States.ALTER_WHO
				self:draw()
			end
			return
		end
		
		if key == 'e' then
			self.state = States.EXCHANGE
			self:draw()
			return
		end
			
		if key == 'b' or key == 'escape' then
			messages:add("You decide to break camp and continue onward.");
			ACTIVESCREEN = nil
			self.showing = false
			self.caller:onScreenClosed()
			return
		end

	end

	if self.state == States.ALTER_WHO then

		if key == 'return' or key == 'escape' then
			self.state = States.IDLE
			self:draw()
			return
		end
		
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= #party.characters then
				self.currentCharacterIndex = tonumber(key)
				self.state = States.ALTER_WHAT
				self:draw()
				return
			end			
		end
		
	end
	
	if self.state == States.ALTER_WHAT then

		if key == 'p' then
			self.state = States.ALTER_ROW
			self:draw()
			return
		end
		
		if key == 'return' or key == 'escape' then
			self.state = States.IDLE
			self:draw()
			return
		end
		
	end	
	
	if self.state == States.ALTER_ROW then

		if key == 'f' then
			self.state = States.IDLE
			party:moveToFront(self.currentCharacterIndex)
			self:draw()
			return
		end
		
		if key == 'r' then
			party:moveToRear(self.currentCharacterIndex)
			self.state = States.IDLE
			self:draw()
			return
		end		
		
		if key == 'return' or key == 'escape' then
			self.state = States.IDLE
			self:draw()
			return
		end
		
	end		

	if self.state == States.EXCHANGE then
	
		if key == 'return' or key == 'escape' then
			self.subState = States.IDLE
			self:draw()
			return
		end
		
		if tonumber(key) and tonumber(key) >= 1 and tonumber(key) <= #party.characters then
			self.selectedCharacterIndex = tonumber(key)
			self.state = States.EXCHANGE_WITH
			self:draw()
			return
		end			
	
	end		
	
	if self.state == States.EXCHANGE_WITH then
	
		if key == 'return' or key == 'escape' then
			self.subState = States.IDLE
			self:draw()
			return
		end
		
		if tonumber(key) and tonumber(key) >= 1 and tonumber(key) <= #party.characters then
			party:exchange(self.selectedCharacterIndex, tonumber(key))
			self.state = States.IDLE
			self:draw()
			return
		end			
	
	end				
	
	if self.state == States.REST_UNTIL then
	
		if key == 'return' or key == 'escape' then
			self.state = States.IDLE
			self:draw()
			return
		end
		
		if key == 'h' then
			messages:add("Everyone feel refreshed!");
			party:restUp()
			self.state = States.IDLE
			self:draw()
			return
		end		

		if key == 'm' then
			messages:add("You rest until morning.");
			self.state = States.IDLE
			self:draw()
			return
		end		
	
	end		
end

return CampScreen
