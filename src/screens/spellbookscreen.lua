local SpellbookScreen = class('SpellbookScreen')

function SpellbookScreen:initialize()
	
end

function SpellbookScreen:init(caller)
end

function SpellbookScreen:show(caller, char, combatmode)

	ACTIVESCREEN = self

	self.caller = caller
	self.canvas = caller.canvas

	self.combatmode = combatmode
	self.currentCharacter = char
	self.showing = true
	self:draw()

end

function SpellbookScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	-- screen
	
	love.graphics.draw(assets.images["screen_spellbook"], 11, 11)

	-- interface

	love.graphics.printf("Spells for "..self.currentCharacter.name, 260, 8, 640, "left")

	-- draw spells

	love.graphics.printf("[#]", 260, 35, 640, "left")
	love.graphics.printf("Spell", 296, 35, 640, "left")
	love.graphics.printf("MPS", -10, 35, 640, "right")
	
	local index = 1
	local yoffset = 55
	local y = 0
	
	for i = 1, #self.currentCharacter.spellbook do
		local spell = spelltemplates:get(self.currentCharacter.spellbook[i])
		love.graphics.printf("["..index.."] "..spell.name, 260, yoffset + y, 640, "left")
		love.graphics.printf(spell.mps_cost, -10, yoffset + y, 640, "right")
		y = y + 15
		index = index + 1
	end
	
	for i = 1, #self.currentCharacter.spellbook do
	end
	
	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function SpellbookScreen:drawCommandbar()

	love.graphics.printf("Choose spell [1-"..#self.currentCharacter.spellbook.."]:", 10, 335, 640, "left")
	
end

function SpellbookScreen:cast(index)

	local spell = spelltemplates:get(self.currentCharacter.spellbook[index])

	if not self.combatmode == true and spell.target_type ~= "party" then
		messages:add("This spell cannot be cast outside of combat.")
		self:draw()
		return
	end

	-- check if caster has enough mana for this spell

	if self.currentCharacter.stats.mps < spell.mps_cost then
		messages:add(self.currentCharacter.name.." doesn't have enough magic points to cast this spell.")
		self:draw()
		return
	end

	self.showing = false
	self.caller:onSelectSpell(spell)

end

function SpellbookScreen:processKey(key)

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
		if tonumber(key) >= 1 and tonumber(key) <= #self.currentCharacter.spellbook then
			--self.currentSpellIndex = tonumber(key)
			self:cast(tonumber(key))
			return
		end			
	end

	if key == 'return' or key == 'escape' then
		ACTIVESCREEN = nil
		self.showing = false
		self.caller:onScreenClosed()
	end	

end

return SpellbookScreen
