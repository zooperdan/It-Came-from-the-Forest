local Atlases = class('Atlases')

function Atlases:initialize()

end

function Atlases:load(tileset)

	local filenames = {}
	
	self.images = {}
	self.jsondata = {}

	if tileset == "city" then
		self.filenames = {
			"enemies",
			"common-props",
			"city-environment",
			"city-props",
			"npc",
		}	
	elseif tileset == "forest" then
		self.filenames = {
			"forest-environment",
			"forest-props",
			"enemies",
			"common-props",
			"npc",
		}	
	elseif tileset == "dungeon" then
		self.filenames = {
			"dungeon-environment",
			"forest-props",
			"enemies",
			"common-props",
			"npc",
		}	
	end


	local numerrors = 0
	local path = "files/atlases/"

	for index = 1, #self.filenames do
	
		local filename = self.filenames[index]
	
		-- load atlas graphics

		if love.filesystem.getInfo(path..filename..".png") then
			self.images[filename] = love.graphics.newImage(path..filename..".png")
		else
			print("Unable to load: "..path..filename..".png")
			numerrors = numerrors + 1
		end
		
		-- load atlas jsons

		file, err = io.open(path..filename..".json", "rb")
		
		if not err and file then
			local jsondata = file:read("*all")
			file:close()
			local data = json.parse(jsondata)

			self.jsondata[filename] = { layer = {}}
			
			for i = 1, #data.layers do
				self.jsondata[filename].layer[data.layers[i].name] = data.layers[i]
			end
			
		else
			print("Unable to load: "..path..filename..".json")
			numerrors = numerrors + 1
		end	

	end

	return (numerrors == 0)

end

return Atlases
