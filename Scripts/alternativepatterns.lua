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