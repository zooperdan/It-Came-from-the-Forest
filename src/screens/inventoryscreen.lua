local InventoryScreen = class('InventoryScreen')

local InventoryStates = {
	IDLE = 0,
	USE = 1,
	EQUIP = 2,
	REMOVE = 3,
	GIVE = 4,
	GIVETO = 5,
	GIVE_HOW_MANY = 6,
	DROP = 7,
	LOOK = 8
}

local inventorySlots = {}
inventorySlots["weapon"] = 1
inventorySlots["shield"] = 1
inventorySlots["head"] = 1
inventorySlots["ears"] = 1
inventorySlots["neck"] = 1
inventorySlots["shoulders"] = 1
inventorySlots["body"] = 1
inventorySlots["wrists"] = 1
inventorySlots["hands"] = 1
inventorySlots["finger"] = 4
inventorySlots["waist"] = 1
inventorySlots["legs"] = 1
inventorySlots["feet"] = 1
inventorySlots["back"] = 1

function InventoryScreen:initialize()
	self.pagelength = 9
end

function InventoryScreen:init(caller)
	self.caller = caller
	self.canvas = caller.canvas
	self.characterIndex = nil
	self.state = InventoryStates.IDLE
end

function InventoryScreen:show(index)
	
	if index ~= self.characterIndex then
		ACTIVESCREEN = self
		self.characterIndex = index
		self.currentCharacter = party.characters[self.characterIndex]
		self.pagecount = math.ceil(#self.currentCharacter.inventory / self.pagelength)
		self.pageindex = 0
		party:updateStats()
		self.showing = true
		self:draw()
	else
		ACTIVESCREEN = nil
		self.characterIndex = nil
		self.showing = false
		self.caller:onScreenClosed()
	end	
	
end

function InventoryScreen:draw()

	if self.showing == false then
		return
	end

	local yoffset = 0

	renderer:begin()

	if self.characterIndex == 1 then
		love.graphics.draw(assets.images["screen_boff"], 11, 11)
	elseif self.characterIndex == 2 then
		love.graphics.draw(assets.images["screen_geledric"], 11, 11)
	else
		love.graphics.draw(assets.images["screen_inventory"], 11, 11)
	end
	
	-- name
	
	love.graphics.printf(self.currentCharacter.name, 260, 8, 640, "left")
	
	-- level, gender, class and exp
	
	love.graphics.printf("LVL"..self.currentCharacter.level.." "..self.currentCharacter.gender.." "..self.currentCharacter.classtype, -10, 8, SCREEN_WIDTH, "right")

	-- stats
	
	love.graphics.printf("STR="..self.currentCharacter.stats.str, 260, yoffset+35, 640, "left")
	love.graphics.printf("VIT="..self.currentCharacter.stats.vit, 260, yoffset+50, 640, "left")
	love.graphics.printf("AGI="..self.currentCharacter.stats.agi, 260, yoffset+65, 640, "left")
	love.graphics.printf("INT="..self.currentCharacter.stats.int, 260, yoffset+80, 640, "left")
	love.graphics.printf("WIL="..self.currentCharacter.stats.wil, 260, yoffset+95, 640, "left")

	love.graphics.printf("ATK="..round(self.currentCharacter.stats.atk), 260, yoffset+165, 640, "left")
	love.graphics.printf("DEF="..round(self.currentCharacter.stats.def), 260, yoffset+180, 640, "left")
	
	love.graphics.printf("EXP="..self.currentCharacter.experience, 340, yoffset+170+10, 640, "left")
	
	local hps = round(self.currentCharacter.stats.hps)
	local mps = round(self.currentCharacter.stats.mps)
	local status = "OK"

	if self.currentCharacter.status == STATUS_DEAD then
		status = "DEAD"
		hps = "NA"
		mps = "NA"
	end
	
	love.graphics.printf("HPS="..hps, 260, yoffset+123, 640, "left")
	love.graphics.printf("MPS="..mps, 260, yoffset+138, 640, "left")
	love.graphics.printf("STATUS="..status, 522, yoffset+170+10, 640, "left")

	-- inventory items

	self.pagecount = math.ceil(#self.currentCharacter.inventory / self.pagelength)

	if self.pageindex >= self.pagecount then
		self.pageindex = self.pagecount-1
	end

	local y = 0
	local yoffset = 35
	local start = self.pageindex*self.pagelength
	local num = #self.currentCharacter.inventory
	
	if num > self.pagelength then
		num = math.min(self.pagelength, #self.currentCharacter.inventory - (self.pageindex*self.pagelength))
	end

	if self.pagecount > 1 and self.pageindex < self.pagecount-1 then
		love.graphics.printf("[DN]", -10, 175-30+10, SCREEN_WIDTH, "right")
	end

	if self.pagecount > 1 and self.pageindex > 0 then
		love.graphics.printf("[UP]", -10, 35, SCREEN_WIDTH, "right")
	end
		
	local index = 1
	
	self.currentPageItemsCount = num
	
	for i = start+1, (start+num) do
		
		if index == 10 then
			index = 0
		end
		if self.currentCharacter.inventory[i].equipped == 1 then
			love.graphics.printf("*", 330, yoffset + y, 640, "left")
		end
		local item = itemtemplates:get(self.currentCharacter.inventory[i].template)
		if self.currentCharacter.inventory[i].stack and self.currentCharacter.inventory[i].stack > 1 then
			love.graphics.printf("["..index.."] "..item.name.." ("..self.currentCharacter.inventory[i].stack..")", 340, yoffset + y, 640, "left")
		else
			if item.flags and item.flags == UNIDENTIFIED then
				love.graphics.printf("["..index.."] ("..item.unidentifiedname..")", 340, yoffset + y, 640, "left")
			else
				love.graphics.printf("["..index.."] "..item.name, 340, yoffset + y, 640, "left")
			end
		end
		y = y + 15
		index = index + 1
	end

	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function InventoryScreen:drawCommandbar()

	if self.state == InventoryStates.IDLE then
		local giveStr = (#party.characters > 1) and "[G]ive  " or ""
		love.graphics.printf("[E]quip  [R]emove  [U]se  "..giveStr.."[D]rop  [L]ook  [B]ack", 10, 335, 640, "left")
	elseif self.state == InventoryStates.EQUIP then
		if self.currentPageItemsCount == 1 then
			love.graphics.printf("Equip which item? [1]: ", 10, 335, 640, "left")
		else
			love.graphics.printf("Equip which item? [1-"..tostring(self.currentPageItemsCount).."]: ", 10, 335, 640, "left")
		end
	elseif self.state == InventoryStates.REMOVE then
		if self.currentPageItemsCount == 1 then
			love.graphics.printf("Remove which item? [1]: ", 10, 335, 640, "left")
		else
			love.graphics.printf("Remove which item? [1-"..tostring(self.currentPageItemsCount).."]: ", 10, 335, 640, "left")
		end
	elseif self.state == InventoryStates.USE then
		if self.currentPageItemsCount == 1 then
			love.graphics.printf("Use which item? [1]: ", 10, 335, 640, "left")
		else
			love.graphics.printf("Use which item? [1-"..tostring(self.currentPageItemsCount).."]: ", 10, 335, 640, "left")
		end
	elseif self.state == InventoryStates.DROP then
		if self.currentPageItemsCount == 1 then
			love.graphics.printf("Drop which item? [1]: ", 10, 335, 640, "left")
		else
			love.graphics.printf("Drop which item? [1-"..tostring(self.currentPageItemsCount).."]: ", 10, 335, 640, "left")
		end
	elseif self.state == InventoryStates.LOOK then
		if self.currentPageItemsCount == 1 then
			love.graphics.printf("Look at which item? [1]: ", 10, 335, 640, "left")
		else
			love.graphics.printf("Look at which item? [1-"..tostring(self.currentPageItemsCount).."]: ", 10, 335, 640, "left")
		end		
	elseif self.state == InventoryStates.GIVE then
		if self.currentPageItemsCount == 1 then
			love.graphics.printf("Give which item? [1]: ", 10, 335, 640, "left")
		else
			love.graphics.printf("Give which item? [1-"..tostring(self.currentPageItemsCount).."]: ", 10, 335, 640, "left")
		end		
	elseif self.state == InventoryStates.GIVETO then
		local num = #party.characters
		love.graphics.printf("Give item to? [1-"..num.."]: ", 10, 335, 640, "left")
	elseif self.state == InventoryStates.GIVE_HOW_MANY then
		local num = self.currentCharacter.inventory[self.giveItemIndex].stack
		love.graphics.printf("How many to give? [1-"..num.."]: ", 10, 335, 640, "left")
	end
	
end

function InventoryScreen:nextPage()
	self.pageindex = self.pageindex + 1
	if self.pageindex >= self.pagecount then
		self.pageindex = self.pagecount-1
	end
end

function InventoryScreen:prevPage()
	self.pageindex = self.pageindex - 1
	if self.pageindex < 0 then
		self.pageindex = 0
	end
end

function InventoryScreen:equippedInSlotCount(slot)

	local num = 0

	for i = 1, #self.currentCharacter.inventory do
		local itemTemplate = itemtemplates:get(self.currentCharacter.inventory[i].template)
		if self.currentCharacter.inventory[i].equipped == 1 then
			if itemTemplate.slot == slot then
				num = num + 1
			end
		end
	end
	
	return num
	
end

function InventoryScreen:unequipFirst(slot)

	for i = 1, #self.currentCharacter.inventory do
		local itemTemplate = itemtemplates:get(self.currentCharacter.inventory[i].template)
		if self.currentCharacter.inventory[i].equipped == 1 then
			if itemTemplate.slot == slot then
				self.currentCharacter.inventory[i].equipped = 0
				return
			end
		end
	end
	
end

function InventoryScreen:equip(index)

	index = self.pageindex*self.pagelength + index

	local itemTemplate = itemtemplates:get(self.currentCharacter.inventory[index].template)

	if itemTemplate.flags and itemTemplate.flags == UNIDENTIFIED then
		messages:add("The item must be identified first.")
		return
	end

	-- check if the item is already equipped
	
	if self.currentCharacter.inventory[index].equipped == 1 then
		messages:add("That item is already equipped.")
		return
	end

	-- check if item is of equippable type
	
	if not itemTemplate.slot or itemTemplate.slot == "" then
		messages:add("\"" .. itemTemplate.name .. "\" cannot be equipped.")
		return
	end

	-- how many of this kind can be equipped at the same time?
	
	local maxequipped = inventorySlots[itemTemplate.slot]
	
	-- find out how many of this kind is already equipped
	
	local equippedCount = self:equippedInSlotCount(itemTemplate.slot)
	
	-- reached max number of equipped items of this kind
	
	if maxequipped > 1 and equippedCount == maxequipped then
		messages:add("You are wearing more than one item in that equipment slot. Please remove an item first before you equip something else.")
		return
	end
	
	if maxequipped == 1 and equippedCount == maxequipped then
		self:unequipFirst(itemTemplate.slot)
	end

	-- equip item

	self.currentCharacter.inventory[index].equipped = 1
	party:updateStats()
	self:draw()

end

function InventoryScreen:remove(index)

	index = self.pageindex*self.pagelength + index

	-- trying to remove an item that isn't already equipped?

	if self.currentCharacter.inventory[index].equipped == nil or self.currentCharacter.inventory[index].equipped == 0 then
		messages:add("That item is not equipped.")
		return
	end

	-- remove item

	self.currentCharacter.inventory[index].equipped = 0
	party:updateStats()
	self:draw()

end

function InventoryScreen:use(index)

	index = self.pageindex*self.pagelength + index

	local item = self.currentCharacter.inventory[index]
	local itemTemplate = itemtemplates:get(item.template)

	if party:useItem(self.currentCharacter, itemTemplate) then
		item.stack = item.stack - 1
		if item.stack == 0 then
			table.remove(self.currentCharacter.inventory, index)
		end
	end

	self:draw()

end

function InventoryScreen:drop(index)

	index = self.pageindex*self.pagelength + index

	local itemTemplate = itemtemplates:get(self.currentCharacter.inventory[index].template)

	if self.currentCharacter.inventory[index] then
		table.remove(self.currentCharacter.inventory, index)
	end

	messages:add("You drop the \"" .. itemTemplate.name .. "\" and it disintegrates into smoke.")
	party:updateStats()
	self:draw()

end

function InventoryScreen:look(index)

	index = self.pageindex*self.pagelength + index

	local itemTemplate = itemtemplates:get(self.currentCharacter.inventory[index].template)

	if itemTemplate.flags and itemTemplate.flags == UNIDENTIFIED then
		messages:add("You see nothing special about it. Perhaps you should have it identified first.")
	else
		if itemTemplate.description then
			messages:add(itemTemplate.description)
		else
			messages:add("You see nothing special about it.")
		end
	end

	self:draw()

end

function InventoryScreen:giveto(charindex)

	local char = party.characters[charindex]

	if char == self.currentCharacter then
		messages:add("Giving an item to yourself makes no sense!")
		return
	end
	
	-- give stacked item
	
	local item = self.currentCharacter.inventory[self.giveItemIndex]

	-- is item of stackable type

	local itemTemplate = itemtemplates:get(item.template)
	local stackable = itemTemplate.stackable ~= nil and itemTemplate.stackable or 0
	
	-- check if target inventory already have this item. if it exists we add to stack

	local itemFound = false

	if stackable == 1 then

		for i = 1, #char.inventory do
			if char.inventory[i].template == item.template then
				char.inventory[i].stack = char.inventory[i].stack and char.inventory[i].stack or 0
				char.inventory[i].stack = char.inventory[i].stack + self.giveItemAmount
				itemFound = true
				item.stack = item.stack - self.giveItemAmount
				break
			end
		
		end

		-- target inventory didn't have this item so we add a new entry

		if itemFound == false then
			table.insert(char.inventory, table.shallow_copy(item))
			char.inventory[#char.inventory].stack = self.giveItemAmount
			item.stack = item.stack - self.giveItemAmount
		end

		-- number is same as stack so we give the whole stack
		
		if item.stack == 0 then
			table.remove(self.currentCharacter.inventory, self.giveItemIndex)
		end

	else

		-- give single item and remove from giver's inventory

		table.insert(char.inventory, table.shallow_copy(item))
		table.remove(self.currentCharacter.inventory, self.giveItemIndex)

	end

end

function InventoryScreen:processKey(key)

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
	
	if self.state == InventoryStates.IDLE then
	
		if key == 'f1' then
			messages:add(table_to_string(self.currentCharacter.stats))
			self:draw()
		end

		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= #party.characters then
				self:show(tonumber(key))
				return
			end
		end			
		
		if key == 'up' then
			self:prevPage()
			self:draw()
			return
		end

		if key == 'down' then
			self:nextPage()
			self:draw()
			return
		end
	
		if key == 'b' or key == 'escape' then
			self.characterIndex = nil
			ACTIVESCREEN = nil
			self.showing = false
			self.caller:onScreenClosed()
			return
		end	


		if key == 'e' then
			self.state = InventoryStates.EQUIP
			self:draw()
		end

		if key == 'r' then
			self.state = InventoryStates.REMOVE
			self:draw()
		end

		if key == 'u' then
			if party:isIncapacitated(self.currentCharacter) then
				messages:add(self.currentCharacter.name.." is not able to do that.")
				self:draw()
				return
			end
			self.state = InventoryStates.USE
			self:draw()
		end

		if key == 'l' then
			self.state = InventoryStates.LOOK
			self:draw()
		end
		
		if key == 'd' then
			if #self.currentCharacter.inventory == 0 then
				messages:add("There's nothing to drop.")
				self:draw()
				return
			end		
			self.state = InventoryStates.DROP
			self:draw()
		end		
		
		if key == 'g' then
			local num = #party.characters
			if num > 1 then
				self.giveItemAmount = 1
				self.state = InventoryStates.GIVE
				self:draw()
			end
		end	
		
		return
	
	end

	if self.state == InventoryStates.EQUIP then
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= self.currentPageItemsCount then
				self:equip(tonumber(key))
				self.state = InventoryStates.IDLE
				self:draw()
				return
			end			
		end
	end

	if self.state == InventoryStates.REMOVE then
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= self.currentPageItemsCount then
				self:remove(tonumber(key))
				self.state = InventoryStates.IDLE
				self:draw()
				return
			end			
		end
	end

	if self.state == InventoryStates.USE then
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= self.currentPageItemsCount then
				self:use(tonumber(key))
				self.state = InventoryStates.IDLE
				self:draw()
				return
			end			
		end
	end	

	if self.state == InventoryStates.DROP then
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= self.currentPageItemsCount then
				self:drop(tonumber(key))
				self.state = InventoryStates.IDLE
				self:draw()
				return
			end			
		end
	end	
	
	if self.state == InventoryStates.LOOK then
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= self.currentPageItemsCount then
				self:look(tonumber(key))
				self.state = InventoryStates.IDLE
				self:draw()
				return
			end			
		end
	end	
	
	if self.state == InventoryStates.GIVE then
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= self.currentPageItemsCount then
				
				self.giveItemIndex = self.pageindex*self.pagelength + tonumber(key)
				
				if self.currentCharacter.inventory[self.giveItemIndex].equipped == 1 then
					messages:add("You should remove the item before giving it away.")
					self.state = InventoryStates.IDLE
					self:draw()
					return
				end
				
				if self.currentCharacter.inventory[self.giveItemIndex].stack then
					if self.currentCharacter.inventory[self.giveItemIndex].stack > 1 then
						self.state = InventoryStates.GIVE_HOW_MANY
						self:draw()
						return
					end
				end
				
				self.state = InventoryStates.GIVETO
				self:draw()
				return
			end			
		end
	end	
	
	
	if self.state == InventoryStates.GIVE_HOW_MANY then
		if tonumber(key) then
			local num = self.currentCharacter.inventory[self.giveItemIndex].stack
			if tonumber(key) >= 1 and tonumber(key) <= num then
				self.giveItemAmount = tonumber(key)
				self.state = InventoryStates.GIVETO
				self:draw()
				return
			end			
		end
	end	
	
	if self.state == InventoryStates.GIVETO then
		if tonumber(key) then
			if tonumber(key) >= 1 and tonumber(key) <= #party.characters then
				self:giveto(tonumber(key))
				self.state = InventoryStates.IDLE
				self:draw()
				return
			end			
		end
	end	
	
	if key == 'return' then
		self.state = InventoryStates.IDLE
		self:draw()
	end

end

return InventoryScreen