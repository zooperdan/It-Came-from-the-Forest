function randomPartyCharacter(row)

	local found = false
	local char = nil
	
	if party:defeated() then
		return nil
	end	
	
	while not found do

		local r = math.random(1, #party.characters)
	
		if party.characters[r].status ~= STATUS_DEAD then
		
			if row and row == party.characters[r].row then
				found = true
				char = party.characters[r]
			else
				found = true
				char = party.characters[r]
			end
		end
		
	end
	
	return char

end

--[[-----------------------------------------------------------------------------------------------------------------------

	randomizeDamage()
	
	randomizes the passed damage value 

-----------------------------------------------------------------------------------------------------------------------]]--

function randomizeDamage(damage)

	local diff = damage * 0.25
	local add = math.random(0, diff*2)-diff

	damage = damage + add;

	if damage < 0 then damage = 0 end
	
	return round(damage)

end

--[[-----------------------------------------------------------------------------------------------------------------------

	getEnemiesInBackRow()
	
	returns the enemies positioned in the front row during combat

-----------------------------------------------------------------------------------------------------------------------]]--

function getEnemiesInFrontRow(enemies)

	local row = {}

	for i = 1, #enemies do
		if enemies[i].row == FRONT_ROW then
			table.insert(row, i)
		end
	end

	return row;

end

--[[-----------------------------------------------------------------------------------------------------------------------

	getEnemiesInBackRow()
	
	returns the enemies positioned in the back row during combat

-----------------------------------------------------------------------------------------------------------------------]]--

function getEnemiesInBackRow(enemies)

	local row = {}

	for i = 1, #enemies do
		if enemies[i].row == BACK_ROW then
			table.insert(row, i)
		end
	end

	return row;

end



--[[-----------------------------------------------------------------------------------------------------------------------

	enemyCanAct()
	
	returns true if the passed in enemy is in a state which it can perform an action

-----------------------------------------------------------------------------------------------------------------------]]--

function enemyCanAct(enemy)

	if enemy.status == STATUS_DEAD then return false end
	if enemy.status == "paralyzed" then return false end

	return true

end

--[[-----------------------------------------------------------------------------------------------------------------------

	playerCanAct()
	
	returns true if the passed in character is in a state which it can perform an action

-----------------------------------------------------------------------------------------------------------------------]]--

function playerCanAct(char)

	if char.status == STATUS_DEAD then return false end

	return true

end

---------------------------------------------------------------------------------------------------------------------------

function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..", "
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-2)
    end
    return result.."}"
end

function checkCriterias(criterias)

	if criterias == "" then
		return false
	end

	-- First split the whole criterias string on | symbol

	if string.sub(criterias,#criterias,#criterias) ~= "|" then
		criterias = criterias.."|"
	end
			
	tokens = {}
	for w in criterias:gmatch("([^|]*[|])") do
		if string.sub(w,#w,#w) == "|" then
			w = string.sub(w,1,#w-1)
		end
		table.insert(tokens, w)
	end		

	-- Then split each criteria on the : symbol

	local numCriteriaMet = 0

	for i = 1,#tokens do

		local criteria = tokens[i]

		if string.sub(criteria,#criteria,#criteria) ~= ":" then
			criteria = criteria..":"
		end
				
		segments = {}
		for w in criteria:gmatch("([^:]*[:])") do
			if string.sub(w,#w,#w) == ":" then
				w = string.sub(w,1,#w-1)
			end
			table.insert(segments, w)
		end	

		if globalvariables:check(segments[1], segments[2], segments[3]) then
			numCriteriaMet = numCriteriaMet + 1
		end
	
	end

	if numCriteriaMet == #tokens then
		return true
	end
	
	return false

end

function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

function explode(line, delimiter)

	if string.sub(line,#line,#line) ~= delimiter then
		line = line..delimiter
	end

	result = {}
	for w in line:gmatch("([^"..delimiter.."]*["..delimiter.."])") do
		if string.sub(w,#w,#w) == delimiter then
			w = string.sub(w,1,#w-1)
		end
		table.insert(result, w)
	end		
	
	return result
	
end

function round(num)
    local under = math.floor(num)
    local upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

--[[
function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end
]]--

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end
