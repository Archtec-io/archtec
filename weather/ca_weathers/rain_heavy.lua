local name = "weather:rain_heavy"

local conditions = {
	min_height		= weather.settings.min_height,
	max_height		= weather.settings.max_height,
	min_heat		= 40,
	min_humidity	= 65,
	indoors			= false
}

local effects = {}

effects["climate_api:skybox"] = {
	cloud_data = {
		color = "#5e676eb5"
	},
	priority = 11
}

effects["climate_api:sound"] = {
	name = "weather_rain_heavy",
	gain = 1
}

effects["weather:lightning"] = 1 / 20

effects["climate_api:particles"] = {
	boxsize = { x = 18, y = 0, z = 18 },
	v_offset = 7,
	velocity = 7,
	amount = 17,
	expirationtime = 1.2,
	minsize = 25,
	maxsize = 35,
	texture = {
		"weather_rain.png",
		"weather_rain.png",
		"weather_rain_medium.png"
	},
	glow = 5
}

climate_api.register_weather(name, conditions, effects)