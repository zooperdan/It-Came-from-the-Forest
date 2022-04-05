class = require "libs/middleclass"
inspect = require "libs/inspect"
lume = require "libs/lume"
json = require "libs/json"

require "globals"
require "util"

Game = require "game"

screen = {width = 640, height = 360}

local game = Game:new()

function love.load(arg)

	game:init()
	
end

function love.update(dt)

	game:update(dt)
	
end

function love.keypressed(key)

	game:handleInput(key)
	
end

function love.draw(dt)
	
	love.graphics.push()
	love.graphics.scale(love.graphics.getWidth() / screen.width)
	love.graphics.draw(game.canvas)
	love.graphics.pop()
	
end
