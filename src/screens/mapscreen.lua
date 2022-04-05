local MapScreen = class('MapScreen')

function MapScreen:initialize()
	
end

function MapScreen:init(caller)

	self.caller = caller
	self.canvas = caller.canvas
	
end

function MapScreen:show()

	ACTIVESCREEN = self
	self.showing = true
	self:draw()
	
end

function MapScreen:draw()

	if self.showing == false then
		return
	end

	renderer:begin()

	local offsety = 6
	
	love.graphics.printf(level.data.name, 260, 8, 640, "left")
	love.graphics.printf("??=WALL", 260, offsety+35, 640, "left")
	love.graphics.printf("??=ENCOUNTER", 260, offsety+50, 640, "left")
	love.graphics.printf("??=NPC", 260, offsety+65, 640, "left")
	love.graphics.printf("??=STORE", 260, offsety+80, 640, "left")
	love.graphics.printf("??=PORTAL", 260, offsety+95, 640, "left")
	love.graphics.printf("??=DOOR", 260, offsety+110, 640, "left")
	love.graphics.printf("??=AREA EXIT", 260, offsety+125, 640, "left")
	love.graphics.printf("??=FOUNTAIN", 260, offsety+140, 640, "left")
	love.graphics.printf("??=CHEST", 260, offsety+155, 640, "left")
	love.graphics.printf("??=BARREL", 260, offsety+170, 640, "left")

	renderer:drawMessageLog()

	self:drawCommandbar()

	renderer:finalize()

end

function MapScreen:drawCommandbar()

	love.graphics.printf("[B]ack", 10, 335, 640, "left")
	
end

function MapScreen:processKey(key)

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
	
	if key == 'b' or key == 'm' or key == 'escape' then
		ACTIVESCREEN = nil
		self.showing = false
		self.caller:onScreenClosed()
	end	

end

return MapScreen
