archtec.settings = {}
local S = archtec.S
local F = minetest.formspec_escape
local C = minetest.colorize
local space = "  "

local callbacks = {}

function archtec.settings.add_callback(func)
	table.insert(callbacks, func)
end

local function on_setting_change(name, setting, newvalue)
	for _, callback in ipairs(callbacks) do
		callback(name, setting, newvalue)
	end
end

local function tobool(v)
	if v == "true" then
		return true
	end
	return false
end

local function set(name, setting, val)
	minetest.log("action", "[archtec_settings] set '" .. setting .. "' of player '" .. name .. "' to '" .. dump(val) .. "'")
	return archtec_playerdata.set(name, "s_" .. setting, val)
end

-- Register playerdata keys here
archtec_playerdata.register_key("s_help_msg", "boolean", true)
archtec_playerdata.register_key("s_tbw_show", "boolean", true)
archtec_playerdata.register_key("s_sp_show", "boolean", true)
archtec_playerdata.register_key("s_r_id", "boolean", true)
archtec_playerdata.register_key("s_snow", "boolean", true)
archtec_playerdata.register_key("s_avd", "boolean", false)

local settings = {
	{type = "header", title = S("Chat")},
	{type = "setting", name = "help_msg", title = S("Show help messages in chat"), description = S("Shows one message every 10 minutes.")},
	{type = "setting", name = "tbw_show", title = S("Show tool breakage warnings"), description = ""},
	{type = "custom", name = "ncolor", title = S("Namecolor in the #main channel"), description = ""},

	{type = "header", title = S("Visual")},
	{type = "setting", name = "sp_show", title = S("Show waypoint to spawn"), description = ""},
	-- disabled {type = "setting", name = "snow", title = S("Enable snow particles"), description = S("Snow particles must also be activated by the admin.")},

	{type = "header", title = S("Misc")},
	{type = "setting", name = "r_id", title = S("Collect dropped items automatically"), description = ""},
	{type = "setting", name = "avd", title = S("Auto-vote \"YES\" on day votes"), description = ""},
}

local setting_list = {}

do
	for _, def in ipairs(settings) do
		if def.type == "setting" or def.type == "custom" then
			setting_list[def.name] = true
		end
	end
end

local function show_settings(name)
	local fs = ""
	local y = 0.1
	for i, def in ipairs(settings) do
		if def.type == "header" then
			fs = fs .. "box[0.3," .. y + 0.2 .. ";10.4,0.5;#c6e8ff]"
			fs = fs .. "label[0.4," .. y + 0.45 .. ";" .. F(def.title) .. "]"
			y = y + 1.2
		elseif def.type == "setting" then
			local s_string = "s_" .. def.name
			local label = F(def.title .. space .. C("#999", def.description))
			local default_val = archtec_playerdata.get_default(s_string)
			local curr_val = archtec_playerdata.get(name, s_string)

			fs = fs .. "checkbox[0.4," .. y .. ";" .. s_string .. ";" .. label .. ";" .. tostring(curr_val) .. "]"
			if default_val ~= curr_val then
				fs = fs .. "image_button[10.2," .. y - 0.2 .. ";0.5,0.5;archtec_reset.png;" .. "reset_" .. def.name .. ";;false;false;]"
				fs = fs .. "tooltip[" .. "reset_" .. def.name .. ";" .. F(S("Reset to default")) .. "]"
			end
			y = y + 0.6
		elseif def.type == "custom" then
			-- Namecolor
			if def.name == "ncolor" then
				local curr_val = archtec_playerdata.get(name, "s_ncolor")

				local colors = C("#999", "List of all colors: ")
				for _, def2 in ipairs(archtec.namecolor.list) do
					colors = colors .. C(def2.color, "█ ")
				end

				local idx = archtec.namecolor.get_idx(curr_val)

				fs = fs .. "dropdown[0.4," .. y .. ";2.5;ncolor;" .. table.concat(archtec.namecolor.list_names, ",") .. ";" .. F(idx) .. ";true]"
				fs = fs .. "label[3," .. y + 0.15 .. ";" .. F(def.title) .. "]"
				fs = fs .. "label[3," .. y + 0.55 .. ";" .. F(colors) .. "]"
				y = y + 1.3
			end
		end
	end
	fs = "formspec_version[4]" .. "size[11," .. y .. "]" .. fs
	minetest.show_formspec(name, "archtec:settings", fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec:settings" then return end
	local name = player:get_player_name()
	for f, v in pairs(fields) do
		local setting, value
		if f:sub(1, 2) == "s_" then
			setting = f:sub(3, #f)
			if setting_list[setting] == nil then return end
			value = tobool(v)
		elseif f:sub(1, 6) == "reset_" then
			setting = f:sub(7, #f)
			if setting_list[setting] == nil then return end
			value = archtec_playerdata.get_default("s_" .. setting)
		end

		if setting ~= nil and value ~= nil then
			set(name, setting, value)
			on_setting_change(name, setting, value)
			show_settings(name)
		end
	end
	-- Custom settings
	if fields.ncolor then
		local def = archtec.namecolor.list[tonumber(fields.ncolor)]
		local curr_val = archtec_playerdata.get(name, "s_ncolor")

		if def ~= nil and def.id ~= curr_val then -- validity check
			archtec_playerdata.set(name, "s_ncolor", def.id)
			show_settings(name)
			minetest.chat_send_player(name, S("[archtec] Your new namecolor looks like this: @1.", C(archtec.namecolor.get(name), name)))
		end
	end
end)

if minetest.get_modpath("unified_inventory") then
	unified_inventory.register_button("settings", {
		type = "image",
		image = "archtec_settings_icon.png",
		tooltip = "Settings",
		action = function(player)
			if player then
				local name = player:get_player_name()
				show_settings(name)
			end
		end
	})
end
