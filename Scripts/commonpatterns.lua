u_execDependencyScript("ohvrvanilla", "base", "vittorio romeo", "commonpatterns.lua")
u_execScript("common.lua")

-- A random collection of walls
function pSpray(mTimes, gap, max)
	local delay = getPerfectDelay(THICKNESS) * (gap or 4)
	for _ = 0, mTimes do
		cWallEx(math.random(0, l_getSides()), math.random(0, max or 2))
		t_wait(delay)
	end
	t_wait(delay * 2)
end