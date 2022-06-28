local modPath = minetest.get_modpath(minetest.get_current_modname())
local scriptsPath = modPath..DIR_DELIM.."scripts"..DIR_DELIM

dofile(scriptsPath.."notifyTeam.lua")
dofile(scriptsPath.."userlimit.lua")
dofile(scriptsPath.."stats.lua")
dofile(scriptsPath.."shutdown.lua")
dofile(scriptsPath.."mapfix.lua")
dofile(scriptsPath.."prejoin.lua")
dofile(scriptsPath.."disallow_new_players.lua")
dofile(scriptsPath.."aliases.lua")
dofile(scriptsPath.."unregister.lua")
dofile(scriptsPath.."rezepte.lua")
dofile(scriptsPath.."spawn.lua")
dofile(scriptsPath.."death_messages.lua")
dofile(scriptsPath.."caverealms.lua")
dofile(scriptsPath.."vote_api.lua")
dofile(scriptsPath.."vote.lua")
dofile(scriptsPath.."idlekick.lua")
dofile(scriptsPath.."skybox.lua")

if minetest.get_modpath("homedecor_wardrobe") then
    dofile(scriptsPath.."homedecor_wardrobe.lua")
end