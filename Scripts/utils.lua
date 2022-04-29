--[[
	Utility functions/constants for Open Hexagon.
	https://github.com/vittorioromeo/SSVOpenHexagon

	Copyright (C) 2021 Ricky Cui

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <https://www.gnu.org/licenses/>.

	Email: cuiricky4@gmail.com
	GitHub: https://github.com/Syyrion
]]

u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "utils.lua")

--[[
	* DIMENSION CONSTANTS
]]
FOCUS_RATIO = 0.625
PLAYER_WIDTH_UNFOCUSED = 23
PLAYER_WIDTH_FOCUSED = PLAYER_WIDTH_UNFOCUSED * FOCUS_RATIO
PLAYER_TIP_DISTANCE_OFFSET = 7.3
PLAYER_BASE_DISTANCE_OFFSET = -2.025
PIVOT_RADIUS_TO_PLAYER_DISTANCE_RATIO = 0.75
PIVOT_BORDER_WIDTH = 5

--[[
	* TIME CONSTANTS
]]
FRAMES_PER_SECOND = FPS
SECONDS_PER_FRAME = 1 / FRAMES_PER_SECOND

TICKS_PER_FRAME = 4
FRAMES_PER_TICK = 1 / TICKS_PER_FRAME

TICKS_PER_SECOND = FRAMES_PER_SECOND * TICKS_PER_FRAME
SECONDS_PER_TICK = 1 / TICKS_PER_SECOND

-- These assume a player speed multiplier of 1
FRAMES_PER_PLAYER_ROTATION = 800 / 21
TICKS_PER_PLAYER_ROTATION = FRAMES_PER_PLAYER_ROTATION * TICKS_PER_FRAME
SECONDS_PER_PLAYER_ROTATION = FRAMES_PER_PLAYER_ROTATION * SECONDS_PER_FRAME

--[[
	* OTHER CONSTANTS
]]
THICKNESS = 40			-- Wall thickness. Sometimes more convenient to define in utils



--[[
	* GENERAL UTILITY
]]

-- No operation function
function __NOP(...) return ... end

-- Similar to __NOP but doesn't return anything
function __NIL(...) end

-- Function that always returns true
function __TRUE(...) return true end

-- Function that always returns false
function __FALSE(...) return false end

-- Common functions for sifting erroneous values
Filter = {}

-- Types
Filter.NIL = function (val) return type(val) == 'nil' end
Filter.NUMBER = function (val) return type(val) == 'number' end
Filter.STRING = function (val) return type(val) == 'string' end
Filter.BOOLEAN = function (val) return type(val) == 'boolean' end
Filter.TABLE = function (val) return type(val) == 'table' end
Filter.FUNCTION = function (val) return type(val) == 'function' end
Filter.THREAD = function (val) return type(val) == 'thread' end
Filter.USERDATA = function (val) return type(val) == 'userdata' end

-- Numeric filters
Filter.POSITIVE = function (val) return Filter.NUMBER(val) and val > 0 end
Filter.NON_NEGATIVE = function (val) return Filter.NUMBER(val) and val >= 0 end
Filter.NEGATIVE = function (val) return Filter.NUMBER(val) and val < 0 end
Filter.NON_POSITIVE = function (val) return Filter.NUMBER(val) and val <= 0 end
Filter.NON_ZERO = function (val) return Filter.NUMBER(val) and val ~= 0 end

Filter.INTEGER = function (val) return Filter.NUMBER(val) and val % 1 == 0 end
Filter.NON_ZERO_INTEGER = function (val) return Filter.INTEGER(val) and val ~= 0 end
Filter.WHOLE = function (val) return Filter.INTEGER(val) and val >= 0 end
Filter.NATURAL = function (val) return Filter.INTEGER(val) and val > 0 end
Filter.SIDE_COUNT = function (val) return Filter.INTEGER(val) and val >= 3 end

-- Returns a table of strings derived from splitting <str> with <pattern>.
function string.split(str, pattern)
	local t, capture = {}, nil
	while true do
		local prev = str
		capture, str = str:match('(.-)' .. pattern .. '(.*)')
		if not capture or str == prev then
			table.insert(t, prev)
			break
		end
		table.insert(t, capture)
	end
	return unpack(t)
end

-- Returns an iterator function that iterates over all split strings.
function string.gsplit(str, pattern)
	return coroutine.wrap(function ()
		local capture
		pattern = '(.-)' .. pattern .. '(.*)'
		while true do
			local prev = str
			capture, str = str:match(pattern)
			if not capture or str == prev then
				coroutine.yield(prev)
				break
			end
			coroutine.yield(capture)
		end
	end)
end

-- Formatted error
function errorf(level, label, message, ...)
	error(('[%sError] '):format(label) .. message:format(...), level + 1)
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

-- Takes a value <i> between <a> and <b> and proportionally maps it to a value between <c> and <d>
function mapValue(i, a, b, c, d)
	return c + ((d - c) / (b - a)) * (i - a)
end

-- Guarantees an input value to be a valid number of sides. Falls back to the level's current number of sides if an invalid argument is given
-- ! Depreciated. Use the function Filter.SIDE_COUNT
function verifyShape(shape)
	return type(shape) == 'number' and math.floor(math.max(shape, 3)) or l_getSides()
end

local __fromHSV = fromHSV

-- fromHSV with type checking
function fromHSV(h, s, v)
	return __fromHSV(type(h) == 'number' and h or 0, type(s) == 'number' and clamp(s, 0, 1) or 1, type(v) == 'number' and clamp(v, 0, 1) or 1)
end



--[[
	* WAVES
]]
Wave = {
	-- Square wave function with period 1 and amplitude 1 at value <x> with duty cycle <d>
	square = function (x, d)
		return -getSign(x % 1 - clamp(d, 0, 1))
	end,

	-- Asymmetrical triangle wave function with period 1 and amplitude 1 at value <x>
	-- Asymmetry can be adjusted with <d>
	-- An asymmetry of 1 is equivalent to sawtooth wave
	-- An asymmetry of 0 is equivalent to a reversed sawtooth wave
	triangle = function (x, d)
		x = x % 1
		d = clamp(d, 0, 1)
		local p, x2 = 1 - d, 2 * x
		return (x < 0.5 * d) and (x2 / d) or (0.5 * (1 + p) <= x) and ((x2 - 2) / d) or ((1 - x2) / p)
	end,

	-- Sawtooth wave function with period 1 and amplitude 1 at value x
	sawtooth = function (x)
		return 2 * (x - math.floor(0.5 + x))
	end
}
-- ! Legacy function names
squareWave = Wave.square
triangleWave = Wave.triangle
sawtoothWave = Wave.sawtooth



--[[
	* DIMENSIONS
]]

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



--[[
	* THICKNESS AND DELAYS
]]

-- Returns the speed of walls in units per frame (5 times the speed mult)
function getWallSpeedInUnitsPerFrame()
	return u_getSpeedMultDM() * 5
end

-- Returns the amount of frames/ticks/seconds it takes for a certain thickness of wall to travel one full length of itself
function thicknessToFrames(th)
	return th / getWallSpeedInUnitsPerFrame()
end

function thicknessToTicks(th)
	return thicknessToFrames(th) * TICKS_PER_FRAME
end

function thicknessToSeconds(th)
	return thicknessToFrames(th) * SECONDS_PER_FRAME
end

-- Inverse of the above functions
function framesToThickness(frames)
	return getWallSpeedInUnitsPerFrame() * frames
end

function ticksToThickness(ticks)
	return framesToThickness(ticks * FRAMES_PER_TICK)
end

function secondsToThickness(seconds)
	return framesToThickness(seconds * FRAMES_PER_SECOND)
end

-- Returns the amount of time in frames/ticks/seconds for the player make one full revolution adjusted for the player speed multiplier.
function getTicksPerPlayerRotation()
	return TICKS_PER_PLAYER_ROTATION * l_getPlayerSpeedMult()
end

function getFramesPerPlayerRotation()
	return FRAMES_PER_PLAYER_ROTATION * l_getPlayerSpeedMult()
end

function getSecondsPerPlayerRotation()
	return SECONDS_PER_PLAYER_ROTATION * l_getPlayerSpeedMult()
end

-- Returns the amount of time in frames/ticks/seconds for the player travel across one side.
function getIdealDelayInTicks(sides)
	return getTicksPerPlayerRotation() / (sides or l_getSides())
end

function getIdealDelayInFrames(sides)
	return getFramesPerPlayerRotation() / (sides or l_getSides())
end

function getIdealDelayInSeconds(sides)
	return getSecondsPerPlayerRotation() / (sides or l_getSides())
end

function getIdealThickness(sides)
	return ticksToThickness(getIdealDelayInTicks(sides))
end

function createSolidPolygonConstructor(sides, fn)
	sides, fn = Filter.SIDE_COUNT(sides) and sides or errorf(2, 'CreatePolygonConstructor', 'Invalid side count.'), type(fn) == "function" and fn or cw_createNoCollision
	local arc, limit, t = math.tau / sides, math.floor(sides / 2), {}
	local a, b = 0, sides - 1
	local aa, ba = 0, b * arc
	repeat
		local key = fn()
		t[key] = {[0] = ba, [1] = aa}
		a, b = a + 1, b - 1
		aa, ba = a * arc, b * arc
		t[key][2] = aa
		t[key][3] = ba
	until b == limit
	return t
end

--[[
	* CLASSES
]]

Discrete = {sieve = __FALSE}
Discrete.__index = Discrete

function Discrete:new(init, def, filter)
	local newInst = setmetatable({}, self)
	newInst.__index = newInst
	newInst:filter(filter)
	newInst:set(init)
	newInst:define(def)
	return newInst
end

-- Sets a value. If verification fails, the value is removed.
function Discrete:set(val) self.val = self.sieve(val) and val or nil end
-- Gets a value.
function Discrete:get() return self.val end
-- Sets the filter.
function Discrete:filter(fn) self.sieve = type(fn) == 'function' and fn or nil end
-- Modifies the behavior of the get function.
function Discrete:define(fn) self.get = type(fn) == 'function' and fn or nil end
-- Gets a value without searching for a default value.
function Discrete:rawget() return rawget(self, 'val') end
-- Sets a value to its default.
function Discrete:freeze()
	self.val = nil
	self.val = self:get()
end

Color = {}
Color.__index = Color

function Color:new(r, g, b, a, def)
	local newInst = setmetatable({}, self)
	newInst.__index = newInst
	newInst:set(r, g, b, a)
	newInst:define(def)
	return newInst
end

function Color:set(r, g, b, a)
	self.r = Filter.NUMBER(r) and r or nil
	self.g = Filter.NUMBER(g) and g or nil
	self.b = Filter.NUMBER(b) and b or nil
	self.a = Filter.NUMBER(a) and a or nil
end

Color.get = s_getMainColor

function Color:define(fn) self.get = type(fn) == 'function' and fn or nil end

function Color:rawget() return rawget(self, 'r'), rawget(self, 'g'), rawget(self, 'b'), rawget(self, 'a') end

function Color:freeze()
	self.r, self.g, self.b, self.a = nil, nil, nil, nil
	self.r, self.g, self.b, self.a = self:get()
end



Incrementer = {value = 0}
Incrementer.__index = Incrementer

function Incrementer:new(start, target, steps)
	local newInst = setmetatable({
		new = __NIL,
		start = Filter.NUMBER(start) and start or error('Argument #1 is not a number', 2),
		target = Filter.NUMBER(target) and target or error('Argument #2 is not a number', 2),
		progress = 0,
		limit = Filter.WHOLE(steps) and steps or error('Argument #3 is not an integer', 2)
	}, self)
	newInst:increment()
	return newInst
end

function Incrementer:restart()
	self.progress = 0
	self:increment()
end

function Incrementer:increment()
	if self.progress > self.limit then return self.value end
	self.value = mapValue(self.progress, 0, self.limit, self.start, self.target)
	self.progress = self.progress + 1
	return self.value
end

function Incrementer:get()
	return self.value
end