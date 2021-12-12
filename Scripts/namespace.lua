Audio = {
	music = {
		play = setmetatable({
			segment = a_setMusicSegment,
			seconds = a_setMusicSeconds
		}, {__call = function (_, musicId) a_setMusic(musicId) end}),
		pitch = {
			sync = a_syncMusicToDM,
			set = a_setMusicPitch
		}
	},
	sound = {
		play = setmetatable({
			buffer = a_playSound
		}, {__call = function (_, filename) a_playPackSound(filename) end}),
		override = {
			beep = a_overrideBeepSound,
			increment = a_overrideIncrementSound,
			swap = a_overrideSwapSound,
			death = a_overrideDeathSound
		}
	}
}

Timeline = {
	eval = t_eval,
	clear = t_clear,
	kill = t_kill,
	wait = setmetatable({
		seconds = setmetatable({
			Until = t_waitUntilS
		}, {__call = function (_, seconds) t_waitS(seconds) end})
	}, {__call = function (_, duration) t_wait(duration) end})
}

Event = {
	eval = e_eval,
	kill = e_kill,
	stopTime = setmetatable({
		seconds = e_stopTimeS
	}, {__call = function (_, duration) e_stopTime(duration) end}),
	wait = setmetatable({
		seconds = setmetatable({
			Until = e_waitUntilS
		}, {__call = function (_, seconds) e_waitS(seconds) end})
	}, {__call = function (_, duration) e_wait(duration) end}),
	message = setmetatable({
		important = setmetatable({
			silent = e_messageAddImportantSilent
		}, {__call = function (_, message, duration) e_messageAddImportant(message, duration) end}),
		clear = e_clearMessages
	}, {__call = function (_, message, duration) e_messageAdd(message, duration) end})
}