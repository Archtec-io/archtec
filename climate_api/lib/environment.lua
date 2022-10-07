local environment = {}

function environment.get_weather_presets(player)
	local pname = player:get_player_name()
	local weathers = climate_mod.current_weather[pname]
	if type(weathers) == "nil" then weathers = {} end
	return weathers
end

function environment.get_effects(player)
	local pname = player:get_player_name()
	local effects = {}
	for effect, players in pairs(climate_mod.current_effects) do
		if type(players[pname]) ~= "nil" then
			table.insert(effects, effect)
		end
	end
	return effects
end

return environment