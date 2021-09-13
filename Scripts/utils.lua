u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "utils.lua")

-- Tests whether a number is equal to any number within an array
function equalsWithin(num, arr)
	for i = 1, #arr do
		if num == arr[i] then return true end
	end
	return false
end

-- Takes a coordinate, translates it by dX and dY, and returns the new coordinates
function transformTranslate(dX, dY, ...)
	local c = {...}
	return c[1] + dX, c[2] + dY
end

-- Takes a coordinate, rotates it by R radians about the origin, and returns the new coordinates
function transformRotation(R, ...)
	local c = {...}
	return c[1] * math.cos(R) - c[2] * math.sin(R), c[1] * math.sin(R) + c[2] * math.cos(R)
end

-- Takes a coordinate, scales it by sX or sY across the x or y axis respectively, and returns the new coordinates
function transformScale(sX, sY, ...)
	local c = {...}
	return c[1] * sY, c[2] * sX
end

-- Sets hue to a specific value by setting its min an max to the same value
function s_setHue(h)
	s_setHueMin(h)
	s_setHueMax(h)
end

-- Sets pilse to a specific value by setting its min an max to the same value
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