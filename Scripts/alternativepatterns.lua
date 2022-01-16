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

u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "alternativepatterns.lua")
u_execScript("common.lua")

function cDoubleBarrage(mSide)
	for i = 1, l_getSides() - 3 do
		cWall(i + mSide + 1)
		cWall(mSide)
	end
end

function pDoubleBarrageSpiral(mTimes)
	local side = getRandomSide()
	local loc = 0
	local dir = getRandomDir()
	local delay = getPerfectDelayDM(THICKNESS) * 6
		for _ = 1, mTimes do
			cDoubleBarrage(side + loc)
			loc = loc + dir
			t_wait(delay)
		end
	t_wait(delay)
end

function pDoubleBarrageInverse(mTimes)
	local side = getRandomSide()
	local loc = 0
	local delay = getPerfectDelayDM(THICKNESS) * 6
		for _ = 1, mTimes do
			cDoubleBarrage(side + loc)
			loc = loc + getHalfSides()
			t_wait(delay)
		end
	t_wait(delay)
end

function pAltHalf(mTimes, gap)
	local side = getRandomSide()
	local sides = l_getSides()
	local delay = getPerfectDelayDM(THICKNESS) * (gap or 6)
	for i = 1, mTimes do
		if i % 2 == 0 then
			cWallEx(side, math.ceil(sides / 2) - 1)
		else
			oWallEx(side, math.floor(sides / 2) - 1)
		end
		t_wait(delay)
	end
	t_wait(delay)
end