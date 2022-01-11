u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "utils.lua")

--[[
	* CONSTANTS
]]

THICKNESS = 40			-- Wall thickness. Sometimes more convenient to define in utils

--[[
	* DIMENSIONS
]]
FOCUS_RATIO = 0.625		-- The percentage by which the player shrinks when focused
PLAYER_WIDTH_UNFOCUSED = 23
PLAYER_WIDTH_FOCUSED = PLAYER_WIDTH_UNFOCUSED * FOCUS_RATIO
PLAYER_TIP_DISTANCE_OFFSET = 7.3
PLAYER_BASE_DISTANCE_OFFSET = -2.025
PIVOT_RADIUS_TO_PLAYER_DISTANCE_RATIO = 0.75
PIVOT_BORDER_WIDTH = 5

--[[
	* TIME
]]
FRAMES_PER_SECOND = FPS
SECONDS_PER_FRAME = 1 / FRAMES_PER_SECOND

TICKS_PER_FRAME = 4
FRAMES_PER_TICK = 1 / TICKS_PER_FRAME

TICKS_PER_SECOND = FRAMES_PER_SECOND * 4
SECONDS_PER_TICK = 1 / TICKS_PER_SECOND

FRAMES_PER_PLAYER_ROTATION = 800 / 21
TICKS_PER_PLAYER_ROTATION = FRAMES_PER_PLAYER_ROTATION * TICKS_PER_FRAME
SECONDS_PER_PLAYER_ROTATION = FRAMES_PER_PLAYER_ROTATION * SECONDS_PER_FRAME


--[[
	* UTILITY
]]

-- No operation function
function nop(...) end

function string.split(s, pattern)
	local pos, t = 1, {}
	repeat
		local i, o = s:find(pattern, pos)
		i = (i or 0) - 1
		table.insert(t, s:sub(pos, i))
		pos = (o or 0) + 1
	until i == -1
	return t
end

function string.gsplit(s, pattern)
	return coroutine.wrap(function ()
		local pos = 1
		repeat
			local i, o = s:find(pattern, pos)
			i = (i or 0) - 1
			coroutine.yield(s:sub(pos, i))
			pos = (o or 0) + 1
		until i == -1
	end)
end

-- Tests whether a table contains a specific value on any existing key
function tableContainsValue(val, table)
	for _, v in pairs(table) do
		if val == v then return true end
	end
	return false
end

-- Takes a coordinate, rotates it by R radians about the origin, and returns the new coordinates
function rotate2DPointAroundOrigin(R, x, y)
	local cos, sin = math.cos(R), math.sin(R)
	return x * cos - y * sin, x * sin + y * cos
end

-- Sets hue to a specific value by setting its min an max to the same value
function forceSetHue(h)
	s_setHueMin(h)
	s_setHueMax(h)
end

-- Sets pulse to a specific value by setting its min an max to the same value
function forceSetPulse(p)
	s_setPulseMin(p)
	s_setPulseMax(p)
end

-- Square wave function with period 1 and amplitude 1 at value <x> with duty cycle <d>
function squareWave(x, d)
	return -getSign(x % 1 - clamp(d, 0, 1))
end

-- Asymmetrical triangle wave function with period 1 and amplitude 1 at value <x>
-- Asymmetry can be adjusted with <d>
-- An asymmetry of 1 is equivalent to sawtooth wave
-- An asymmetry of 0 is equivalent to a reversed sawtooth wave
function triangleWave(x, d)
	x = x % 1
	d = clamp(d, 0, 1)
	local p, x2 = 1 - d, 2 * x
	return (x < 0.5 * d) and (x2 / d) or (0.5 * (1 + p) <= x) and ((x2 - 2) / d) or ((1 - x2) / p)
end

-- Sawtooth wave function with period 1 and amplitude 1 at value x
function sawtoothWave(x)
	return 2 * (x - math.floor(0.5 + x))
end

-- Takes a value <i> between <a> and <b> and proportionally maps it to a value between <c> and <d>
function mapValue(i, a, b, c, d)
	return c + ((d - c) / (b - a)) * (i - a)
end

-- Guarantees an input value to be a valid number of sides. Falls back to the level's current number of sides if an invalid argument is given
function verifyShape(shape)
	return type(shape) == 'number' and math.floor(math.max(shape, 3)) or l_getSides()
end

local __fromHSV = fromHSV

-- fromHSV with type checking
function fromHSV(h, s, v)
	return __fromHSV(type(h) == 'number' and h or 0, type(s) == 'number' and clamp(s, 0, 1) or 1, type(v) == 'number' and clamp(v, 0, 1) or 1)
end

-- Distance from the center to the player position
function getDistanceBetweenCenterAndPlayer()
	return l_getRadiusMin() * l_getPulse() / l_getPulseMin() + l_getBeatPulse()
end
-- Distance from center to tip of player arrow
function getDistanceBetweenCenterAndPlayerTip()
	return getDistanceBetweenCenterAndPlayer() + PLAYER_TIP_DISTANCE_OFFSET
end

-- Distance from center to base of player arrow (depends on focus)
function getDistanceBetweenCenterAndPlayerBase(mFocus)
	return getDistanceBetweenCenterAndPlayer() + PLAYER_BASE_DISTANCE_OFFSET * (mFocus and FOCUS_RATIO or 1)
end

-- Distance from the base to the tip of the player triangle (depends on focus)
function getPlayerHeight(mFocus)
	return PLAYER_TIP_DISTANCE_OFFSET - PLAYER_BASE_DISTANCE_OFFSET * (mFocus and FOCUS_RATIO or 1)
end

-- Base width of the player triangle (depends on focus)
function getPlayerBaseWidth(mFocus)
	return mFocus and PLAYER_WIDTH_FOCUSED or PLAYER_WIDTH_UNFOCUSED
end

-- Half of the base width of the player triangle (depends on focus)
function getPlayerHalfBaseWidth(mFocus)
	return getPlayerBaseWidth(mFocus) * 0.5
end

-- Radius of a circle circumscribed around the center polygon cap
function getCapRadius()
	return getDistanceBetweenCenterAndPlayer() * PIVOT_RADIUS_TO_PLAYER_DISTANCE_RATIO
end

-- Radius of a circle circumscribed around the center polygon
function getPivotRadius()
	return getCapRadius() + PIVOT_BORDER_WIDTH
end

-- Returns the speed of walls in units per frame (5 times the speed mult)
function getWallSpeedInUnitsPerFrame()
	return u_getSpeedMultDM() * 5
end