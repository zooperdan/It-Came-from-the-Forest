settings = {
	musicVolume = 0,
	sfxVolume = 1,
	inventoryX = 119,
	inventoryY = 50,
	inventorySlotsStartX = 251,
	inventorySlotsStartY = 57,
}

startingArea = "forest-1"
fadeColor = {0,0,0}
fadeMusicVolume = {v = settings.musicVolume}
inventoryDragSource = {}

GameStates = {
	INIT = 0,
	EXPLORING = 1,
	LOADING_LEVEL = 2,
	FATAL_ERROR = 3,
	MAIN_MENU = 4,
	BUILDUP1 = 5,
	BUILDUP2 = 6,
	BUILDUP3 = 7,
	BUILDUP4 = 8,
	CREDITS = 9,
	ABOUT = 10,
	SETTINGS = 11
}

SubStates = {
	IDLE = 0,
	AUTOMAPPER = 1,
	INVENTORY = 2,
	SELECT_SPELL = 3,
	POPUP = 4
}

gameState = GameStates.LOADING_LEVEL


highlightshader = love.graphics.newShader[[
extern float WhiteFactor;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(WhiteFactor);
    return outputcolor;
}
]]
