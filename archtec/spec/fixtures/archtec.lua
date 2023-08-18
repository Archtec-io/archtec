-- Load full archtec mod

mineunit("core")
mineunit("player")
mineunit("protection")
mineunit("common/after")
mineunit("server")
mineunit("voxelmanip")

mineunit:set_modpath("archtec", "../archtec")
mineunit:set_current_modname("archtec")
local sp = minetest.get_modpath("archtec") .. "/scripts/"

archtec = {}
archtec.S = minetest.get_translator("archtec")

-- Load api files
sourcefile(sp .. "common")
sourcefile(sp .. "notifyTeam")
sourcefile(sp .. "settings")
sourcefile(sp .. "ignore")
-- sourcefile(sp .. "privs")
sourcefile(sp .. "privs_cache")

-- Fixes
archtec.sp_add = function(...)
	-- dummy function
end

discord = {}
discord.send = function(...)
	-- dummy function
end