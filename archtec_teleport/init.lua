--Archtec_teleport based on https://github.com/minetest-mods/teleport-request

local MP = minetest.get_modpath(minetest.get_current_modname())

archtec_teleport = {
	tpr_list = {},
	tp2me_list = {},
	tpn_list = {}
}

-- Clear requests when the player leaves
minetest.register_on_leaveplayer(function(name)
	if archtec_teleport.tpr_list[name] then
		archtec_teleport.tpr_list[name] = nil
		return
	end

	if archtec_teleport.tp2me_list[name] then
		archtec_teleport.tp2me_list[name] = nil
		return
	end

    if archtec_teleport.tpn_list[name] then
		archtec_teleport.tpn_list[name] = nil
		return
	end
end)

-- Timeout delay
archtec_teleport.timeout_delay = 60

dofile(MP.."/privileges.lua")
dofile(MP.."/functions.lua")
dofile(MP.."/commands.lua")
