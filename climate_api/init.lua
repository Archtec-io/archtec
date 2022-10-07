-- warn about outdated Minetest versions
assert(minetest.add_particlespawner, "[Climate API] This mod requires a more current version of Minetest")

-- initialize global API interfaces
climate_api = {}
climate_mod = {}

-- set mod path for file imports
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- load settings from config file
climate_mod.settings = {
	damage			= true,
	particles		= true,
	skybox			= true,
	sound			= true,
	seasons			= true,
	block_updates	= true,
	heat			= 0,
	humidity		= 0,
	time_spread		= 1,
	particle_count	= 0.5,
	tick_speed		= 1,
	volume			= 0.5,
	ceiling_checks	= 5,
}

climate_mod.i18n = minetest.get_translator("climate_api")

-- initialize empty registers
climate_mod.weathers = {}
climate_mod.effects = {}
climate_mod.cycles = {}
climate_mod.global_environment = {}
climate_mod.global_influences = {}
climate_mod.influences = {}
climate_mod.current_weather = {}
climate_mod.current_effects = {}
climate_mod.forced_weather = {}
climate_mod.forced_enviroment = {}

-- import core API
climate_api = dofile(modpath .. "/lib/api.lua")
climate_api.utility = dofile(modpath .. "/lib/api_utility.lua")
climate_api.skybox = dofile(modpath .. "/lib/skybox_merger.lua")
climate_api.player_physics = dofile(modpath .. "/lib/player_physics.lua")
climate_api.environment = dofile(modpath .. "/lib/environment.lua")
climate_mod.trigger = dofile(modpath .. "/lib/trigger.lua")

-- start event loop and register chat commands
dofile(modpath .. "/lib/main.lua")
dofile(modpath .. "/lib/commands.lua")

-- register environment influences
dofile(modpath .. "/lib/influences.lua")

-- import predefined environment effects
dofile(modpath .. "/ca_effects/damage.lua")
dofile(modpath .. "/ca_effects/particles.lua")
dofile(modpath .. "/ca_effects/skybox.lua")
dofile(modpath .. "/ca_effects/sound.lua")

print("[archtec_weather/climate_api] loaded")
