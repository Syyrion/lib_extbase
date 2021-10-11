u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "utils.lua")

-- Constants
THICKNESS = 40			-- Wall thickness. Sometimes more convenient to define in utils
FOCUSRATIO = 0.625		-- The percentage by which the player shrinks when focused


function math.fastsin_taylor(x)
	x = (x - math.pi) % math.tau - math.pi
	return x - x ^ 3 / 6 + x ^ 5 / 120 - x ^ 7 / 5040 + x ^ 9 / 362880
end

function math.fastcos_taylor(x)
	x = (x - math.pi) % math.tau - math.pi
	return 1 - x ^ 2 / 2 + x ^ 4 / 24 - x ^ 6 / 720 + x ^ 8 / 40320
end


-- Tests whether a number is equal to any number within a table
function equalsWithin(num, arr)
	for i = 1, #arr do
		if num == arr[i] then return true end
	end
	return false
end

-- Takes a coordinate, translates it by dX and dY, and returns the new coordinates
function transformTranslate(dX, dY, x, y)
	return x + dX, y + dY
end

-- Takes a coordinate, rotates it by R radians about the origin, and returns the new coordinates
function transformRotation(R, x, y)
	return x * math.cos(R) - y * math.sin(R), x * math.sin(R) + y * math.cos(R)
end

-- Takes a coordinate, scales it by sX or sY across the x or y axis respectively, and returns the new coordinates
function transformScale(sX, sY, x, y)
	return x * sY, x * sX
end

-- Transformation functions can be chained
-- Ex: transformTranslate(20, 10, transformRotation(math.pi, x, y))

-- Sets hue to a specific value by setting its min an max to the same value
function s_setHue(h)
	s_setHueMin(h)
	s_setHueMax(h)
end

-- Sets pulse to a specific value by setting its min an max to the same value
function s_setPulse(p)
	s_setPulseMin(p)
	s_setPulseMax(p)
end

-- Sign function
function sgn(x)
	return x > 0 and 1 or x == 0 and 0 or -1
end

-- Square wave function with period p at value x with duty cycle d (range [-1, 1])
function square(x, p, d)
	return sgn(math.sin(math.pi * (2 * x / p + 0.5 - d)) - math.cos(math.pi * d))
end

-- Triangle wave function with period p at value x (range [-1, 1])
function triangle(x, p)
	return math.asin(math.sin(math.tau * x / p)) * 2 / math.pi
end

-- Sawtooth wave function with period p at value x (range [-1, 1])
function sawtooth(x, p)
	return 2 * (x / p - math.floor(0.5 + x / p))
end

-- Takes a value <i> between <a> and <b> and proportionally maps it to a value between <c> and <d>
function map(i, a, b, c, d)
	return lerp(c, d, inverseLerp(a, b, i))
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
function getPlayerRadius()
	return l_getRadiusMin() * l_getPulse() / l_getPulseMin() + l_getBeatPulse()
end
-- Distance from center to tip of player arrow
function getPlayerTipRadius()
	return getPlayerRadius() + 7.25
end

-- Distance from center to base of player arrow (depends on focus)
function getPlayerBaseRadius(mFocus)
	return getPlayerRadius() - (mFocus and 1.265625 or 2.025)
end

-- Distance from the base to the tip of the player triangle (depends on focus)
function getPlayerHeight(mFocus)
	return 7.25 + (mFocus and 1.265625 or 2.025)
end

-- Half of the base width of the player triangle (depends on focus)
function getPlayerHalfBaseWidth(mFocus)
	return mFocus and 11.5 or 7.1875
end

-- Base width of the player triangle (depends on focus)
function getPlayerBaseWidth(mFocus)
	return mFocus and 23 or 14.375
end

-- Radius of a circle circumscribed around the center polygon cap
function getCapRadius()
	return getPlayerRadius() * 0.75
end

-- Width of the polygon border
function getPolygonBorderWidth()
	return 5
end

-- Radius of a circle circumscribed around the center polygon
function getPolygonRadius()
	return getCapRadius() + getPolygonBorderWidth()
end

-- Returns the speed of walls in units per frame (5 times the speed mult)
function getWallSpeed()
	return l_getSpeedMult() * 5
end
