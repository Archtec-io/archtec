--[[
	Copyright (C) 2023-24 Niklp <nik@niklp.net>
	GNU Lesser General Public License v2.1 See LICENSE.txt for more information
]]
--

archtec_playerdata = {
	api_version = 2,
}

-- Init some basic stuff
local storage = minetest.get_mod_storage()
local modpath = minetest.get_modpath("archtec_playerdata")
local datadir = minetest.get_worldpath() .. "/archtec_playerdata/"
local type = type

-- Config stuff
local debug_mode = minetest.settings:get_bool("archtec_playerdata.debug_mode", false)
local save_interval = minetest.settings:get("archtec_playerdata.save_interval") or 180 -- 3min
local unload_data_after = minetest.settings:get("archtec_playerdata.unload_data_after") or 3600 -- 1h
local auto_backup_interval = minetest.settings:get("archtec_playerdata.auto_backup_interval") or 86400 -- 1d

-- System structure
local data = {}
local system = {
	mode = "startup", -- modes: running, startup, shutdown
	types = {
		boolean = true,
		number = true,
		string = true,
		table = true,
	},
	keys = {
		system_data_unload = {key_type = "number", default_value = 0, temp = true},
		system_data_modified = {key_type = "boolean", default_value = false, temp = true},
	},
	keys_remove = {},
	upgrades = {},
}

-- Logging and error helpers
local function log_debug(func, str)
	if debug_mode then
		minetest.log("action", "[archtec_playerdata] " .. func .. "() " .. str)
	end
end

local function log_action(func, str)
	minetest.log("action", "[archtec_playerdata] " .. func .. "() " .. str)
end

local function log_error(func, str)
	minetest.log("warning", "[archtec_playerdata] " .. func .. "() " .. str)
	archtec.notify_team(
		"[archtec_playerdata] Something went wrong, error message: "
			.. "[archtec_playerdata] "
			.. func
			.. "() "
			.. str
			.. "."
	)
end

local function api_error(func, str)
	error("[archtec_playerdata] " .. func .. "() " .. str, 2)
end

-- Validation helpers
local function valid_player(name)
	if name ~= "" and type(name) == "string" then
		return true
	end
	return false
end

-- Other helpers
local function dumpx(...) -- dump to one line
	if debug_mode then
		return dump(...):gsub("\n", ""):gsub("\t", "")
	else -- no need to dump tables outside of debug mode
		return ""
	end
end

local function get_user_list()
	local list = {}
	local keys = storage:to_table().fields

	for key, _ in pairs(keys) do
		if key:sub(1, 7) == "player_" then
			list[#list + 1] = key:sub(8, #key)
		end
	end
	return list
end

local function get_loaded_user_list()
	local list = {}
	for name, _ in pairs(data) do
		list[#list + 1] = name
	end

	return list
end

local function get_unload_timestamp()
	return os.time() + unload_data_after
end

local function bool_to_str(bool)
	if bool then
		return "true"
	else
		return "false"
	end
end

local function format_list(list)
	local str = ""
	for k, v in pairs(list) do
		str = str .. k .. "=" .. v .. "; "
	end
	return str
end

-- Basic system functions
local function data_load(name, keep, create)
	if data[name] then
		if keep then -- reset unload timestamp if a player rejoins before cache timeout
			data[name].system_data_unload = 0
		end
		log_debug("data_load", "data of '" .. name .. "' already loaded")
		return true
	end

	local raw = storage:get_string("player_" .. name)
	if create and raw == "" then
		raw = "{}"
	elseif raw == "" then
		log_error("data_load", "tried to load data of not exisiting player '" .. name .. "'")
		return false
	end

	local data_table = minetest.parse_json(raw)
	if data_table == nil then
		log_error("data_load", "failed to parse data of '" .. name .. "'; raw json '" .. raw .. "'")
		return false
	end

	if keep then
		data_table.system_data_unload = 0
	else
		data_table.system_data_unload = get_unload_timestamp()
	end

	data[name] = data_table
	log_debug("data_load", "loaded data of '" .. name .. "'; " .. dumpx(data_table))
	return true
end

local function data_save(name, unload_now)
	if not data[name] then
		log_error("data_save", "data of '" .. name .. "' not available - can't save")
		return false
	end

	local data_copy = table.copy(data[name])
	local unload_data = data_copy.system_data_unload ~= 0 and data_copy.system_data_unload < os.time()

	if not data_copy.system_data_modified then -- don't save data
		log_debug("data_save", "skipped data of '" .. name .. "' since nothing has changed")

		if unload_data or unload_now then
			data[name] = nil
			if unload_data then
				log_debug("data_save", "unloaded data of '" .. name .. "' due to cache timeout")
			end
		end

		return false
	end

	for key_name, _ in pairs(data_copy) do
		if system.keys[key_name] and system.keys[key_name].temp == true then
			data_copy[key_name] = nil
		end
	end

	local raw = minetest.write_json(data_copy)
	if raw == nil then
		log_error("data_save", "failed to generate json for '" .. name .. "'; lua table " .. dumpx(data_copy))
		return false
	end

	if raw == "null" then -- write_json returns "null" when we pass a table w/ 0 key-value pairs
		log_debug("data_save", "failed to generate proper json for '" .. name .. "'; no keys set for this user")
		return false
	end

	storage:set_string("player_" .. name, raw)
	log_debug("data_save", "saved data of '" .. name .. "'; " .. raw .. "")
	data[name].system_data_changed = false

	if unload_data or unload_now then
		data[name] = nil
		if unload_data then
			log_debug("data_save", "unloaded data of '" .. name .. "' due to cache timeout")
		end
	end

	return true
end

-- Backup system
local function backup_create()
	local storage_copy = storage:to_table().fields
	local data_copy = {}

	-- Convert stored data back to lua tables
	for k, v in pairs(storage_copy) do
		if k:sub(1, 7) == "player_" then
			data_copy[k] = minetest.parse_json(v)
			if data_copy[k] == nil then
				log_error("backup_create", "failed to parse json of '" .. k .. "'")
			end
		else
			data_copy[k] = v
		end
	end

	local json_dump = minetest.write_json(data_copy)
	if json_dump == nil then
		log_error("backup_create", "failed to create json string from table")
		return false
	end

	local filename = "archtec_playerdata_" .. os.date("!%Y-%m-%d_%H:%M:%S", os.time()) .. ".txt" -- 2024-01-01_20:00:00
	local success = minetest.safe_file_write(datadir .. filename, json_dump)
	if not success then
		log_error("backup_create", "failed to write backup file - unknown engine error")
		return false
	end

	local backup_size = math.ceil(#json_dump / 1024) -- 1 KiB = 1024 Bytes
	log_action("backup_create", "created backup file " .. filename .. "; file is " .. backup_size .. " KiB big")
	return true
end
archtec_playerdata.backup_create = backup_create

local function backup_restore(filename)
	if system.mode ~= "startup" then
		log_error("backup_restore", "called outside of 'startup' mode")
		return false
	end

	local file = io.open(datadir .. filename, "r")
	if file == nil then
		log_error("backup_restore", "couldn't open backup file '" .. filename .. "'")
		return false
	end

	local raw = file:read("*all")
	file:close()
	if raw == nil then
		log_error("backup_restore", "failed to read buffer from backup file '" .. filename .. "'")
		return false
	end

	local data_copy = minetest.parse_json(raw)
	if data_copy == nil then
		log_error("backup_restore", "failed to parse json from backup file '" .. filename .. "'")
		return false
	end

	-- Convert data back to json strings
	for k, v in pairs(data_copy) do
		if k:sub(1, 7) == "player_" then
			data_copy[k] = minetest.write_json(v)
			if data_copy[k] == nil then
				log_error("backup_restore", "failed to write json of '" .. k .. "'")
			end
		else
			data_copy[k] = v
		end
	end

	local storage_copy = {fields = data_copy}
	storage:from_table(storage_copy)
	log_action("backup_restore", "restored backup from file '" .. filename .. "'")
	return true
end
archtec_playerdata.backup_restore = backup_restore

minetest.register_chatcommand("playerdata_backup", {
	description = "Backup playerdata to world directory",
	privs = {server = true},
	func = function(name)
		minetest.log("action", "[/playerdata_backup] executed by '" .. name .. "'")
		if backup_create() then
			minetest.chat_send_player(name, "Backed-up playerdata.")
		else
			minetest.chat_send_player(name, "Backup failed, please check the logs!")
		end
	end,
})

-- Callbacks to engine
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	data_load(name, true, true)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	archtec_playerdata.set(name, "system_data_unload", get_unload_timestamp())
end)

local time_save = 0
local time_backup = 0
minetest.register_globalstep(function(dtime)
	time_save = time_save + dtime
	time_backup = time_backup + dtime

	if time_save > save_interval then
		time_save = 0
		local users = get_loaded_user_list()
		local saved = {}
		local t0 = minetest.get_us_time()
		for _, name in ipairs(users) do
			if data_save(name) then
				saved[#saved + 1] = name
			end
		end
		local t1 = minetest.get_us_time()

		if #users > 0 then
			log_action(
				"save_step",
				"saved data of "
					.. #saved
					.. " player(s) in "
					.. (t1 - t0) / 1000
					.. " ms; data of "
					.. #users
					.. " player(s) is loaded"
			)
		end
	end

	if time_backup > auto_backup_interval then
		time_backup = 0
		backup_create()
	end
end)

minetest.register_on_shutdown(function()
	system.mode = "shutdown"

	local users = get_loaded_user_list()
	local t0 = minetest.get_us_time()
	for _, name in ipairs(users) do
		data_save(name, true)
	end
	local t1 = minetest.get_us_time()

	if #users > 0 then
		log_action("on_shutdown", "saved data of " .. #users .. " player(s) in " .. (t1 - t0) / 1000 .. " ms")
	end
end)

-- Setup procedure
local function run_actions()
	local list = get_user_list()
	local stats = {
		keys_remove = {},
		upgrades = {},
		unknown_keys = {},
		wrong_type = {},
	}

	system.mode = "running" -- switch to running mode so mods can modify things in upgrades
	for _, name in ipairs(list) do
		data_load(name)

		-- Remove keys scheduled for deletion
		for _, key in ipairs(system.keys_remove) do
			if data[name][key] then
				data[name][key] = nil
				stats.keys_remove[key] = (stats.keys_remove[key] or 0) + 1
				log_debug("run_actions", "removed key '" .. key .. "' of player '" .. name .. "'")
			end
		end

		-- Run upgrades
		for identifier, def in pairs(system.upgrades) do
			if storage:get_int("system_upgrade_" .. identifier) == 0 or def.run_always then
				if data[name][def.key_name] ~= nil then -- value set for this player
					local value = data[name][def.key_name]
					if type(value) == "table" then
						value = table.copy(data[name][def.key_name])
					end

					local result = def.func(name, value)
					if result ~= nil then
						archtec_playerdata.set(name, def.key_name, result)
					end
				end
				stats.upgrades[identifier] = true
			end
		end

		-- Check for unknown keys
		for key, _ in pairs(data[name]) do
			if system.keys[key] == nil then
				stats.unknown_keys[key] = (stats.unknown_keys[key] or 0) + 1
				log_error("run_actions", "found unknown key '" .. key .. "' in data of '" .. name .. "'")
			end
		end

		-- Type checks
		for key, value in pairs(data[name]) do
			if system.keys[key] and system.keys[key].key_type ~= type(value) then
				stats.wrong_type[key] = (stats.wrong_type[key] or 0) + 1
				log_error(
					"run_actions",
					"found " .. key .. "=" .. dumpx(value) .. " with wrong type in data of '" .. name .. "'"
				)
			end
		end

		data_save(name, true)
	end

	-- Mark upgrades as executed
	for identifier, _ in pairs(stats.upgrades) do
		if system.upgrades[identifier].run_always == false then
			storage:set_int("system_upgrade_" .. identifier, 1)
		end
		log_action("run_actions", "executed upgrade '" .. identifier .. "'")
	end

	if #stats.keys_remove > 0 then
		log_action("run_actions", "removed keys from database: " .. format_list(stats.keys_remove))
	end
	if #stats.unknown_keys > 0 then
		log_error("run_actions", "found unknown keys in database: " .. format_list(stats.unknown_keys))
	end
	if #stats.wrong_type > 0 then
		log_error("run_actions", "found keys with wrong value-types in database: " .. format_list(stats.wrong_type))
	end
end

minetest.register_on_mods_loaded(function()
	if not minetest.mkdir(datadir) then
		error("[archtec_playerdata] Failed to create datadir directory '" .. datadir .. "'")
	end

	-- Database maintenance procedure
	log_action("setup", "starting database maintenance procedure")
	backup_create()
	run_actions()
	log_action("setup", "startup procedure done")
end)

-- Register key
function archtec_playerdata.register_key(key_name, key_type, default_value, temp)
	if system.mode ~= "startup" then
		api_error("register_key", "tried to register key after startup")
	end
	if system.keys[key_name] then
		api_error("register_key", "'key_name' is already registered")
	end

	if type(key_name) ~= "string" then
		api_error("register_key", "'key_name' must be a string")
	end
	if not system.types[key_type] then
		api_error("register_key", "unsupported type for 'key_type'")
	end
	if not system.types[type(default_value)] then
		api_error("register_key", "unsupported type for 'default_value'")
	end
	if type(temp) ~= "boolean" and temp ~= nil then
		api_error("register_key", "'temp' is not a boolean value")
	end
	if key_name:sub(1, 7) == "system_" then
		api_error("register_key", "'key_name' must not start with 'system_*'")
	end

	if temp == nil then
		temp = false
	end

	system.keys[key_name] = {key_type = key_type, default_value = default_value, temp = temp}
	log_debug(
		"register_key",
		"registered key '"
			.. key_name
			.. "' with type="
			.. key_type
			.. ", default_value="
			.. dumpx(default_value)
			.. ", temp="
			.. bool_to_str(temp)
	)
end

function archtec_playerdata.register_upgrade(key_name, identifier, run_always, func)
	if system.mode ~= "startup" then
		api_error("register_upgrade", "tried to register upgrade after startup")
	end
	if not system.keys[key_name] then
		api_error("register_upgrade", "key '" .. key_name .. "' does not exist")
	end
	if type(identifier) ~= "string" then
		api_error("register_upgrade", "'identifier' must be a string")
	end
	if type(run_always) ~= "boolean" then
		api_error("register_upgrade", "'run_always' must be a boolean")
	end
	if type(func) ~= "function" then
		api_error("register_upgrade", "'func' must be a function")
	end

	for _, def in ipairs(system.upgrades) do
		if def.identifier == identifier then
			api_error("register_upgrade", "identifier '" .. identifier .. " is already in use")
		end
	end

	system.upgrades[identifier] = {key_name = key_name, run_always = run_always, func = func}
	log_debug("register_upgrade", "registered upgrade '" .. identifier .. "' for key '" .. key_name .. "'")
end

function archtec_playerdata.register_removal(key_name)
	if system.mode ~= "startup" then
		api_error("register_removal", "tried to register removal after startup")
	end
	if type(key_name) ~= "string" then
		api_error("register_removal", "'key_name' must be a string")
	end
	if system.keys[key_name] ~= nil then
		api_error("register_removal", "key '" .. key_name .. "' has been registered, cannot remove")
	end

	system.keys_remove[#system.keys_remove + 1] = key_name
	log_debug("register_removal", "registered key removal '" .. key_name .. "'")
end

-- Check if player is in the database
function archtec_playerdata.player_exists(name)
	local raw = storage:get_string("player_" .. name)
	if raw == "" then
		log_debug("player_exists", "player " .. name .. " does not exist")
		return false
	end
	return true
end

-- Get default_value of key
function archtec_playerdata.get_default(key_name)
	local key = system.keys[key_name]
	if key then
		if key.key_type == "table" then
			return table.copy(key.default_value)
		else
			return key.default_value
		end
	end
	log_debug("get_default", "key '" .. key_name .. "' does not exist")
end

-- Get value of key
function archtec_playerdata.get(name, key_name)
	if not valid_player(name) then
		log_error("get", "tried to get data of non player object " .. dump(name))
		return
	end

	if system.keys[key_name] == nil then
		log_error("get", "tried to get value of unknown key '" .. key_name .. "'")
		return
	end

	if not data_load(name) then
		log_error("get", "data_load() failed")
		return system.keys[key_name].default_value
	end

	local value
	if data[name][key_name] ~= nil then
		if system.keys[key_name].key_type == "table" then
			value = table.copy(data[name][key_name])
		else
			value = data[name][key_name]
		end
	else -- use default value
		if system.keys[key_name].key_type == "table" then
			value = table.copy(system.keys[key_name].default_value)
		else
			value = system.keys[key_name].default_value
		end
	end

	log_debug("get", "returned key " .. key_name .. "=" .. dumpx(value) .. " of '" .. name .. "'")
	return value
end

function archtec_playerdata.get_all(name)
	if not valid_player(name) then
		log_error("get_all", "tried to get all data of non player object " .. dump(name))
		return
	end

	if not data_load(name) then
		log_error("get_all", "data_load() failed")
		return
	end

	local data_copy = table.copy(data[name])
	for key_name, def in pairs(system.keys) do -- add all missing default values
		if data_copy[key_name] == nil then
			if def.key_type == "table" then
				data_copy[key_name] = table.copy(def.default_value)
			else
				data_copy[key_name] = def.default_value
			end
		end
	end

	log_debug("get_all", "returned all data of '" .. name .. "' " .. dumpx(data_copy))
	return data_copy
end

function archtec_playerdata.get_db()
	local storage_copy = storage:to_table().fields
	local data_copy = {}

	-- Convert stored data back to lua tables
	for k, v in pairs(storage_copy) do
		if k:sub(1, 7) == "player_" then
			data_copy[k] = minetest.parse_json(v)
			if data_copy[k] == nil then
				log_error("get_db", "failed to parse json of '" .. k .. "'")
			end
		end
	end

	return data_copy
end

function archtec_playerdata.set(name, key_name, value)
	if not valid_player(name) then
		log_error("set", "tried to set data of non player object " .. dump(name))
		return false
	end

	if not system.keys[key_name] then
		log_error("set", "tried to set unknown key '" .. key_name .. "'")
		return false
	end

	if type(value) ~= system.keys[key_name].key_type then
		log_error(
			"set",
			"tried to set '" .. key_name .. "' of '" .. name .. "' to wrong data type '" .. type(value) .. "'"
		)
		return false
	end

	if not data_load(name) then
		log_error("set", "data_load() failed")
		return false
	end

	if type(value) == "table" then
		-- Todo: add recursive key type check here?
		data[name][key_name] = table.copy(value)
	else
		data[name][key_name] = value
	end
	log_debug("set", "set '" .. key_name .. "' of '" .. name .. "' to " .. dumpx(value))
	data[name].system_data_changed = true

	if system.mode == "shutdown" then
		data_save(name, true)
	end
	return true
end

function archtec_playerdata.mod(name, key_name, value)
	if not valid_player(name) then
		log_error("mod", "tried to mod data of non player object " .. dump(name))
		return false
	end

	if not system.keys[key_name] then
		log_error("mod", "tried to mod unknown key '" .. key_name .. "'")
		return false
	end

	if system.keys[key_name].key_type ~= "number" then
		log_error("mod", "tried to mod '" .. key_name .. "' which uses '" .. system.keys[key_name].key_type .. "'")
		return false
	end

	if type(value) ~= "number" then
		log_error(
			"mod",
			"tried to mod '" .. key_name .. "' of '" .. name .. "' with wrong data type '" .. type(key_name) .. "'"
		)
		return false
	end

	if not data_load(name) then
		log_error("mod", "data_load() failed")
		return false
	end

	local old_value = data[name][key_name]
	if old_value == nil then
		old_value = system.keys[key_name].default_value
	end

	data[name][key_name] = old_value + value
	log_debug(
		"mod",
		"set '" .. key_name .. "' of '" .. name .. "' to '" .. data[name][key_name] .. "' (add '" .. value .. "')"
	)
	data[name].system_data_changed = true

	if system.mode == "shutdown" then
		data_save(name, true)
	end
	return true
end

minetest.register_chatcommand("playerdata_debug", {
	description = "Turn on/off API debug mode",
	privs = {server = true},
	func = function(name)
		minetest.log("action", "[/playerdata_debug] executed by '" .. name .. "'")
		debug_mode = not debug_mode
		if debug_mode then
			minetest.chat_send_player(name, "[archtec_playerdata] Enabled debug mode.")
		else
			minetest.chat_send_player(name, "[archtec_playerdata] Disabled debug mode.")
		end
	end,
})

-- Load other stuff
dofile(modpath .. "/stats.lua")
