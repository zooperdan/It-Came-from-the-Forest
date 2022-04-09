settings = {
	quickstart = true,
	startingArea = "city",
	musicVolume = 0,
	sfxVolume = 1,
	inventoryX = 119,
	inventoryY = 50,
	inventorySlotsStartX = 251,
	inventorySlotsStartY = 57,
	prices = {
		antsacs = 20,
	},
}

isFading = false
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
	POPUP = 4,
	NPC = 5,
	VENDOR_ANTSACS = 6
}

gameState = GameStates.LOADING_LEVEL

world_hitboxes = {}
world_hitboxes["door"] = {x = 225, y = 10, w = 230, h = 325}
world_hitboxes["npc"] = {x = 264, y = 72, w = 115, h = 215}
world_hitboxes["portal"] = {x = 233, y = 58, w = 180, h = 244}
world_hitboxes["chest"] = {x = 248, y = 199, w = 146, h = 99}
world_hitboxes["well"] = {x = 233, y = 58, w = 180, h = 244}
world_hitboxes["prop"] = {x = 233, y = 58, w = 180, h = 244}
world_hitboxes["button"] = {x = 252, y = 217, w = 24, h = 24}

highlightshader = love.graphics.newShader[[
extern float WhiteFactor;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(WhiteFactor);
    return outputcolor;
}
]]
