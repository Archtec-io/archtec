--Archtec_teleport based on https://github.com/minetest-mods/teleport-request 
--WIP

local MP = minetest.get_modpath(minetest.get_current_modname())

tp = {
	tpr_list = {},
	tphr_list = {},
    tpc_list = {},
	tpn_list = {}
}

-- Clear requests when the player leaves
minetest.register_on_leaveplayer(function(name)
	if tp.tpr_list[name] then
		tp.tpr_list[name] = nil
		return
	end

	if tp.tphr_list[name] then
		tp.tphr_list[name] = nil
		return
	end

    if tp.tpn_list[name] then
		tp.tpn_list[name] = nil
		return
	end
end)

-- Timeout delay
tp.timeout_delay = 60

-- Message color
tp.message_color = "#FF8800"

-- Spam prevention
tp.spam_prevention = true

dofile(MP.."/privileges.lua")
dofile(MP.."/functions.lua")
dofile(MP.."/commands.lua")
