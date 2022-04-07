settings = {
	musicVolume = 1,
	sfxVolume = 1
}

startingArea = "forest-2"

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
}

SubStates = {
	IDLE = 0,
	AUTOMAPPER = 1,
	PUSH_BUTTON = 2,
	SELECT_SPELLCASTER = 3,
	SELECT_PLAYER_SPELL_TARGET = 4
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
