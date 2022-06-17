local modPath = minetest.get_modpath(minetest.get_current_modname())
local scriptsPath = modPath..DIR_DELIM.."scripts"..DIR_DELIM

dofile(scriptsPath.."notifyTeam.lua")
dofile(scriptsPath.."userlimit.lua")
dofile(scriptsPath.."inv_move.lua")
dofile(scriptsPath.."stats.lua")
dofile(scriptsPath.."shutdown.lua")
dofile(scriptsPath.."mapfix.lua")
dofile(scriptsPath.."prejoin.lua")
dofile(scriptsPath.."disallow_new_players.lua")
dofile(scriptsPath.."unknown.lua")
dofile(scriptsPath.."unregister.lua")
dofile(scriptsPath.."rezepte.lua")
dofile(scriptsPath.."spawn.lua")

minetest.register_alias("myblocks:brick", "graystone:brick")