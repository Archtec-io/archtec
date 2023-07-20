archtec.settings = {}
local S = archtec.S
local FS = function(...) return minetest.formspec_escape(S(...)) end

local callbacks = {}

function archtec.settings.add_callback(func)
	table.insert(callbacks, func)
end

local function on_setting_change(name, setting, newvalue)
	for _, callback in ipairs(callbacks) do
		callback(name, setting, newvalue)
	end
end

local function get(name, setting)
	return tostring(archtec_playerdata.get(name, "s_" .. setting) or false)
end

local function tobool(v) if v == "true" then return true end return false end

local function set(name, setting, val)
	minetest.log("action", "[archtec_settings] set '" .. setting .. "' of player '" .. name .. "' to '" .. dump(val) .. "'")
	return archtec_playerdata.set(name, "s_" .. setting, val)
end

-- y + 0.5
local function show_settings(name)
	local formspec = [[
		formspec_version[4]
		size[8,8.5]
		label[0.3,0.4;]] .. FS("Chat") .. [[]
		checkbox[0.6,0.9;s_help_msg;]] .. FS("Show help messages in chat") .. [[;]] .. get(name, "help_msg") .. [[]
		checkbox[0.6,1.4;s_tbw_show;]] .. FS("Show tool breakage warnings") .. [[];]] .. get(name, "tbw_show") .. [[]
		label[0.3,1.9;]] .. FS("Misc") .. [[]
		checkbox[0.6,2.4;s_sp_show;]] .. FS("Show a waypoint to the spawn") .. [[;]] .. get(name, "sp_show") .. [[]
		checkbox[0.6,2.9;s_r_id;]] .. FS("Collect dropped items automatically") .. [[;]] .. get(name, "r_id") .. [[]
	]]
	minetest.show_formspec(name, "archtec:settings", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec:settings" then return end
	local name = player:get_player_name()
	for f, v in pairs(fields) do
		if f:sub(1, 2) == "s_" then
			local setting = f:sub(3, #f)
			local val = tobool(v)
			set(name, setting, val)
			on_setting_change(name, setting, val)
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
				-- minetest.log("action", "[archtec_settings] UI button pressed by '" .. name .. "'")
				show_settings(name)
			end
		end
	})
end
