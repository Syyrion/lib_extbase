if __EXTBASE_UTILS_IMPORTED then return end
__EXTBASE_UTILS_IMPORTED = true

u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "utils.lua")

-- Constants
THICKNESS = 40			-- Wall thickness. Sometimes more convenient to define in utils
FOCUS_RATIO = 0.625		-- The percentage by which the player shrinks when focused
PLAYER_WIDTH_UNFOCUSED = 23
PLAYER_WIDTH_FOCUSED = PLAYER_WIDTH_UNFOCUSED * FOCUS_RATIO


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

-- Square wave function with period p at value x with duty cycle d (range [-1, 1])
function squareWave(x, p, d)
	return getSign(math.sin(math.pi * (2 * x / p + 0.5 - d)) - math.cos(math.pi * d))
end

-- Triangle wave function with period p at value x (range [-1, 1])
function triangleWave(x, p)
	return math.asin(math.sin(math.tau * x / p)) * 2 / math.pi
end

-- Sawtooth wave function with period p at value x (range [-1, 1])
function sawtoothWave(x, p)
	return 2 * (x / p - math.floor(0.5 + x / p))
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
    return getDistanceBetweenCenterAndPlayer() + 7.25
end

-- Distance from center to base of player arrow (depends on focus)
function getDistanceBetweenCenterAndPlayerBase(mFocus)
    return getDistanceBetweenCenterAndPlayer() - 2.025 * (mFocus and FOCUS_RATIO or 1)
end

-- Distance from the base to the tip of the player triangle (depends on focus)
function getPlayerHeight(mFocus)
    return 7.25 + 2.025 * (mFocus and FOCUS_RATIO or 1)
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
    return getDistanceBetweenCenterAndPlayer() * 0.75
end

-- Width of the polygon border
function getPivotBorderWidth()
    return 5
end

-- Radius of a circle circumscribed around the center polygon
function getPivotRadius()
    return getCapRadius() + getPivotBorderWidth()
end

-- Returns the speed of walls in units per frame (5 times the speed mult)
function getWallSpeedInUnitsPerFrame()
    return u_getSpeedMultDM() * (u_getDifficultyMult() ^ 0.65) * 5
end