local name = "weather:ambient"

local conditions = {}

-- see https://en.wikipedia.org/wiki/Cloud_base
local function calc_cloud_height()
	local base = weather.settings.cloud_height
	-- much lower scale like 20 instead of 1000 fitting for Minetest
	local scale = weather.settings.cloud_scale
	local spread = 30
	local variation = spread / 4.4 * scale * 0.3
	return base + climate_api.utility.rangelim(variation, -scale, scale)
end

local function generate_effects(params)
	local override = {}

	local cloud_height = calc_cloud_height()

	local skybox = {priority = 10}
	skybox.cloud_data = {
		density = 0.4,
		speed = 3,
		thickness = 7,
		height = cloud_height,
		ambient = "#0f0f1050"
	}

	skybox.sky_data = {
		type = "regular",
		clouds = true,
		sky_color = {
			day_sky = "#6a828e",
			day_horizon = "#5c7a8a",
			dawn_sky = "#b2b5d7",
			dawn_horizon = "#b7bce1",
			night_sky = "#2373e1",
			night_horizon = "#315d9b"
		}
	}
	skybox.cloud_data.color = "#828e97b5"
	skybox.cloud_data.ambient = "#20212250"

	override["climate_api:skybox"] = skybox
	return override
end

climate_api.register_weather(name, conditions, generate_effects)
