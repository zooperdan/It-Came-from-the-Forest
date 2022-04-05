local Assets = class('Assets')

function Assets:initialize()
	
	self.images = {}
	self.fonts = {}
	self.jsons = {}
	self.music = {}
	self.sfx = {
		footsteps = {
			city = {},
			forest = {}
		},
		misc = {}
	}
	
end

function Assets:load()

	local city_footsteps = {
		"walk-stone-1.wav",
		"walk-stone-2.wav",
		"walk-stone-3.wav",
		"walk-stone-4.wav",
		"walk-stone-5.wav",
		"walk-stone-6.wav",
		"walk-stone-7.wav"
	}
	
	for i = 1, #city_footsteps do
		table.insert(self.sfx.footsteps.city, love.audio.newSource("files/sfx/"..city_footsteps[i], "static"))
	end
	
	local forest_footsteps = {
		"walk-grass-1.wav",
		"walk-grass-2.wav",
		"walk-grass-3.wav",
		"walk-grass-4.wav",
		"walk-grass-5.wav",
		"walk-grass-6.wav",
		"walk-grass-7.wav"
	}	

	for i = 1, #forest_footsteps do
		table.insert(self.sfx.footsteps.forest, love.audio.newSource("files/sfx/"..forest_footsteps[i], "static"))
	end
	
	local misc_sounds = {
		"city-gate",
		"door-blocked",
		"door-locked",
		"bushes",
		"drink-fountain",
	}	

	for i = 1, #misc_sounds do
		self.sfx.misc[misc_sounds[i]] = love.audio.newSource("files/sfx/"..misc_sounds[i]..".wav", "static")
	end	

	self.images["sky"] = love.graphics.newImage("files/sky.png")

	self.music["forest"] = love.audio.newSource("files/music/It_Came_from_the_Forest.mp3", "stream")
	self.music["forest"]:setLooping(true)

	self.music["city"] = love.audio.newSource("files/music/It_Came_from_the_Forest.mp3", "stream")
	self.music["city"]:setLooping(true)

	self.fonts["main"] = love.graphics.newFont("files/fonts/Berry Rotunda.ttf", 16, "none", love.graphics.getDPIScale())
	
end

function Assets:playSound(value)

	if type(value) == 'string' then
		local sound = self.sfx.misc[value]
		if sound then
			sound:setVolume(settings.sfxVolume)
			sound:play()
		end
	elseif type(value) == 'userdata' then
		value:setVolume(settings.sfxVolume)
		value:play()
	end
	
end

return Assets
