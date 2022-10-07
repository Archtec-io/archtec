local S = climate_mod.i18n

-- register weather privilege in order to modify the weather status
minetest.register_privilege("weather", {
	description = S("Make changes to the current weather"),
	give_to_singleplayer = false
})

-- display general information on current weather
minetest.register_chatcommand("weather", {
	description = S("Display weather information"),
	func = function(playername)
		local player = minetest.get_player_by_name(playername)
		local ppos = player:get_pos()
		local weathers = climate_api.environment.get_weather_presets(player)
		local effects = climate_api.environment.get_effects(player)
		local msg = ""
		if #weathers > 0 then
			msg = msg .. S("The following weather presets are active for you:") .. " "
			for _, weather in ipairs(weathers) do
				msg = msg .. weather .. ", "
			end
			msg = msg:sub(1, #msg-2) .. "\n"
		else
			msg = msg .. S("Your sky is clear. No weather presets are currently active.") .. "\n"
		end
		if #effects > 0 then
			msg = msg .. S("As a result, the following environment effects are applied:") .. " "
			for _, effect in ipairs(effects) do
				msg = msg .. effect .. ", "
			end
			msg = msg:sub(1, #msg-2) .. "\n"
		end
		minetest.chat_send_player(playername, msg)
	end
})

-- display current mod config
minetest.register_chatcommand("weather_settings", {
	description = S("Print the active Climate API configuration"),
	func = function(playername)
		minetest.chat_send_player(playername, S("Current Settings") .. "\n================")
		for setting, value in pairs(climate_mod.settings) do
			minetest.chat_send_player(playername, dump2(value, setting))
		end
	end
})

-- force a weather preset or disable it
minetest.register_chatcommand("set_weather", {
	params ="<weather> <status>",
	description = S("Turn the specified weather preset on or off for all players or reset it to automatic"),
	privs = { weather = true },
	func = function(playername, param)
		local arguments = {}
		for w in param:gmatch("%S+") do table.insert(arguments, w) end
		local weather = arguments[1]
		if weather == nil or climate_mod.weathers[weather] == nil then
			minetest.chat_send_player(playername, S("Unknown weather preset"))
			return
		end
		local status
		if arguments[2] == nil or arguments[2] == "" then
			arguments[2] = "on"
		end
		if arguments[2] == "on" then
			status = true
		elseif arguments[2] == "off" then
			status = false
		elseif arguments[2] == "auto" then
			status = nil
		else
			minetest.chat_send_player(playername, S("Invalid weather status. Set the preset to either on, off or auto."))
			return
		end
		climate_mod.forced_weather[weather] = status
		minetest.chat_send_player(playername, S("Weather @1 successfully set to @2", weather, arguments[2]))
	end
})

-- list all weather presets and whether they have been forced or disabled
minetest.register_chatcommand("weather_status", {
	description = S("Prints which weather presets are enforced or disabled"),
	func = function(playername)
		minetest.chat_send_player(playername, S("Current activation rules:") .. "\n================")
		for weather, _ in pairs(climate_mod.weathers) do
			local status = "auto"
			if climate_mod.forced_weather[weather] == true then
				status = "on"
			elseif climate_mod.forced_weather[weather] == false then
				status = "off"
			end
			minetest.chat_send_player(playername, dump2(status, weather))
		end
	end
})

-- show all environment influences and their values for the executing player
minetest.register_chatcommand("weather_influences", {
	description = S("Prints which weather influences cause your current weather"),
	func = function(playername)
		minetest.chat_send_player(playername, S("Current influences rules:") .. "\n================")
		local player = minetest.get_player_by_name(playername)
		local influences = climate_mod.trigger.get_player_environment(player)
		for influence, value in pairs(influences) do
			minetest.chat_send_player(playername, dump2(value, influence))
		end
	end
})