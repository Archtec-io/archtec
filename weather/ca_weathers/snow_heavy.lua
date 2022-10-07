local name = "weather:snow_heavy"

local conditions = {
	min_height 		= weather.settings.min_height,
	max_height 		= weather.settings.max_height,
	max_heat		= 30,
	min_humidity	= 65,
	indoors			= false,
}

local effects = {}

effects["climate_api:skybox"] = {
	cloud_data = {
		color = "#5e676eb5"
	},
	priority = 11
}

effects["climate_api:particles"] = {
	boxsize = { x = 14, y = 3, z = 14 },
	v_offset = 3,
	expirationtime = 7.5,
	size = 15,
	amount = 6,
	velocity = 0.75,
	texture = "weather_snow.png",
	glow = 6
}

climate_api.register_weather(name, conditions, effects)
