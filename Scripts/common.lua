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

u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "common.lua")

-- cWall: creates a wall with the common THICKNESS or mThickness (optional)
function cWall(mSide, mThickness, ...) w_wall(mSide, mThickness or THICKNESS) end

-- oWall: creates a wall opposite to the mSide passed
function oWall(mSide, mThickness, ...) cWall(mSide + getHalfSides(), mThickness, ...) end

-- rWall: union of cwall and owall (created 2 walls facing each other)
function rWall(mSide, mThickness, ...)
    cWall(mSide, mThickness, ...)
    oWall(mSide, mThickness, ...)
end

-- cWallEx: creates a wall with mExtra walls attached to it
function cWallEx(mSide, mExtra, mThickness, ...)
    local loopDir = mExtra > 0 and 1 or -1
    for i = 0, mExtra, loopDir do cWall(mSide + i, mThickness, ...) end
end

-- oWallEx: creates a wall with mExtra walls opposite to mSide
function oWallEx(mSide, mExtra, mThickness, ...)
    cWallEx(mSide + getHalfSides(), mExtra, mThickness, ...)
end

-- rWallEx: union of cwallex and owallex
function rWallEx(mSide, mExtra, mThickness, ...)
    cWallEx(mSide, mExtra, mThickness, ...)
    oWallEx(mSide, mExtra, mThickness, ...)
end

-- cBarrageN: spawns a barrage of walls, with a free mSide plus mNeighbors
function cBarrageN(mSide, mNeighbors, mThickness, ...)
    for i = mNeighbors, l_getSides() - 2 - mNeighbors do
        cWall(mSide + i + 1, mThickness, ...)
    end
end

-- cBarrage: spawns a barrage of walls, with a single free mSide
function cBarrage(mSide, mThickness, ...) cBarrageN(mSide, 0, mThickness, ...) end

-- cBarrageOnlyN: spawns a barrage of wall, with only free mNeighbors
function cBarrageOnlyN(mSide, mNeighbors, mThickness, ...)
    cWall(mSide, mThickness, ...)
    cBarrageN(mSide, mNeighbors, mThickness, ...)
end

-- cAltBarrage: spawns a barrage of alternate walls
function cAltBarrage(mSide, mStep, mThickness, ...)
    for i = 0, l_getSides() / mStep, 1 do
        cWall(mSide + i * mStep, mThickness, ...)
    end
end