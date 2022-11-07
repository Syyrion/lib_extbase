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