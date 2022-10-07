local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

weather = {}
weather.settings = {}
weather.settings.fire			= true
weather.settings.lightning		= 20
weather.settings.max_height		= 120
weather.settings.min_height		= -30
weather.settings.cloud_height	= 120
weather.settings.cloud_scale	= 40

local S = minetest.get_translator("weather")
weather.i18n = S

-- import individual weather types
dofile(modpath .. "/ca_weathers/ambient.lua") --clouds and wind
dofile(modpath .. "/ca_weathers/deep_cave.lua") --dark sky in caves
dofile(modpath .. "/ca_weathers/hail.lua") --hail
dofile(modpath .. "/ca_weathers/rain.lua") --rain
dofile(modpath .. "/ca_weathers/rain_heavy.lua") --heavy rain
dofile(modpath .. "/ca_weathers/snow.lua") --snow
dofile(modpath .. "/ca_weathers/snow_heavy.lua") --heavy snow

-- register environment effects
dofile(modpath .. "/ca_effects/lightning.lua")

-- register ABM cycles
dofile(modpath .. "/abms/fire.lua")
