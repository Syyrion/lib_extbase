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
	return t
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
	sides, fn = verifyShape(sides), type(fn) == "function" and fn or cw_createNoCollision
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

-- Function to prevent creating new classes from already existing instances.
function __NEW_CLASS_ERROR()
	error('[NewClassError] Cannot create a new class from already existing instance.', 2)
end
Discrete = {
	form = 'nil'
}
Discrete.__index = Discrete

function Discrete:new(init, def, form)
	local newInst = setmetatable({}, self)
	newInst.__index = newInst
	newInst.form = form
	newInst:set(init)
	newInst:define(def)
	return newInst
end

-- Sets a value. If verification fails, the value is removed.
function Discrete:set(val) self.val = type(val) == self.form and val or nil end
-- Gets a value.
function Discrete:get() return self.val end
-- Modifies the behavior of the get function.
function Discrete:define(fn) self.get = type(fn) == "function" and fn or nil end
-- Gets a value without searching for a default value.
function Discrete:rawget() return rawget(self, 'val') end
-- Sets a value to its default.
function Discrete:freeze()
	self.val = nil
	self.val = self:get()
end

Incrementer = {
	value = 0
}
Incrementer.__index = Incrementer

function Incrementer:new(start, target, steps)
	local newInst = setmetatable({
		start = type(start) == 'number' and start or error('Argument #1 is not a number', 2),
		target = type(target) == 'number' and target or error('Argument #2 is not a number', 2),
		progress = 0,
		limit = type(steps) == 'number' and math.floor(steps) or error('Argument #3 is not a number', 2)
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