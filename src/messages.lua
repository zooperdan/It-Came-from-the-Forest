local Messages = class('Messages')

function Messages:initialize()
	self.list = {}
	self.listindex = 1
	self.linelength = 61
end

function Messages:add(text)

	if #text > self.linelength then
		
		local li = 0
		
		while #text > self.linelength do
			
			local line = string.sub(text,1,self.linelength)
			local startpos = 1
			local endpos = string.len(line)
			local found = false
			
			for i = 1, string.len(line) do
				if string.sub(line, -i, -i) == " " and found == false then
					endpos = string.len(line)-i
					found = true
				end
			end
			

			line = string.sub(text,startpos, endpos)
			
			if li == 0 then
				line = "> " .. line
			else
				line = "  " .. line
			end
			
			
			table.insert(self.list, line)
		
			text = string.sub(text,endpos+1)
			
			if string.sub(text,1,1) == " " then
				text = string.sub(text, 2)
			end
			
			li = li + 1
		end
		
		if #text > 0 then
			table.insert(self.list, "  " .. text)
		end
		
	else
		table.insert(self.list, "> " .. text)
	end
	if #self.list > 7 then
		self.listindex = #self.list - 6
	end
end

function Messages:clear()
	self.list = {}
	self.listindex = 1
end

function Messages:scrollUp()
	if #self.list > 6 and self.listindex < #self.list - 6 then
		self.listindex = self.listindex + 1
	end
end

function Messages:scrollDown()
	if #self.list > 6 and self.listindex > 1 then
		self.listindex = self.listindex - 1
	end
end

return Messages