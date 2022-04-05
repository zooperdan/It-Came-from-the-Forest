local NPCScreen = class('NPCScreen')

local NPCStates = {
	IS_IDLE = 0
}

function NPCScreen:initialize()
	
end

function NPCScreen:init(caller)
	self.caller = caller
	self.canvas = caller.canvas
end

function NPCScreen:show(npc)

	ACTIVESCREEN = self

	self.npc = npc;


	if self.npc.state == 3 then
		-- triggered/done
		messages:add(npc.name .. " says: \"" .. npc.questdonetext .. "\"")
	else
	
		if checkCriterias(npc.criterias) then
			messages:add(npc.name .. " says: \"" .. npc.questdelivertext .. "\"")
			messages:add("Each alive character gain "..npc.experience.." experience points.")
			if npc.gold then
				messages:add("The party receive "..npc.gold.." gold coins.")
				party:addGold(npc.gold)
			end
			party:addExperience(npc.experience)
			
			self.npc.state = 3
			globalvariables:add(self.npc.id, "state", 3)
			level:applyVars(self.npc.vars)
			
		else
			messages:add(npc.name .. " says: \"" .. npc.text .. "\"")
		end
	
	end

	self.showing = true
	
	self:draw()

end

function NPCScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	if self.npc.imageid then
		love.graphics.draw(assets.images["screen_"..self.npc.imageid], 11, 11)
	end

	renderer:drawStatusOverview()
	renderer:drawCharacterList()

	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function NPCScreen:drawCommandbar()

	love.graphics.printf("Press [SPACE] to continue", 10, 335, 640, "left")
	
end

function NPCScreen:processKey(key)

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
	
	if key == 'space' then
		ACTIVESCREEN = nil
		self.showing = false
		self.caller:onScreenClosed()
		return
	end
	
end

return NPCScreen
