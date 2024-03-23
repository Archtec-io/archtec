--[[
	Copyright (C) 2023-24 Niklp <nik@niklp.net>
	GNU Lesser General Public License v2.1 See LICENSE.txt for more information
]]--

archtec_playerdata = {}

-- Init some basic stuff
local storage = minetest.get_mod_storage()
local datadir = minetest.get_worldpath() .. "/archtec_playerdata/"
local S = minetest.get_translator("archtec_playerdata")
local F = minetest.formspec_escape
local FS = function(...) return F(S(...)) end
local type, C = type, minetest.colorize
local json_clean_table = minetest.write_json({})

-- Config stuff
local debug_mode = true --minetest.settings:get_bool("archtec_playerdata.debug_mode", false)
local save_interval = minetest.settings:get("archtec_playerdata.save_interval") or 180

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
	keys = {},
	keys_remove = {},
	upgrades = {},
}

-- Logging and error helpers
local function log_debug(func, str)
	if debug_mode then
		minetest.log("action", "[archtec_playerdata] " .. func .. "() ".. str)
	end
end

local function log_action(func, str)
	minetest.log("action", "[archtec_playerdata] " .. func .. "() ".. str)
end

local function log_error(func, str)
	minetest.log("warning", "[archtec_playerdata] " .. func .. "() ".. str)
	notifyTeam("[archtec_playerdata] Something went wrong, error message: \"" .. "[archtec_playerdata] " .. str .. "\".")
end

local function api_error(func, str)
	-- TBD: handle proper shutdown
	error("[archtec_playerdata] " .. func .. "() ".. str, 1)
end

-- Validation helpers
local function valid_player(name)
	if name ~= "" and type(name) == "string" then
		return true
	end
	return false
end

-- Basic system functions
local function data_load(name, create)
	if not valid_player(name) then
		return false
	end

	if data[name] then
		log_debug("data_load", "data of '" .. name .. "' already loaded")
		return true
	end

	local raw = storage:get_string("player_" .. name)
	if create and raw == "" then
		storage:set_string("player_" .. name, json_clean_table)
		raw = json_clean_table
	elseif raw == "" then
		return false
	end

	local data_table = minetest.parse_json(raw)
	if data_table == nil then
		log_error("data_load", "failed to parse data of '" .. name .. "'; raw json '" .. raw .. "'")
		return false
	end

	data[name] = data_table
	log_debug("data_load", "loaded data of '" .. name .. "'; " .. dump(data_table))
	return true
end

local function data_save(name)
	if not data[name] then
		log_error("data_save", "data of '" .. name .. "' not available - can't save")
		return false
	end

	local raw = minetest.write_json(data[name])
	if raw == nil then
		log_error("data_save", "failed to generate json for '" .. name .. "'; lua table " .. dump(data[name]))
		return false
	end

	storage:set_string("player_" .. name, raw)
	log_debug("data_save", "saved data of '" .. name .. "'; '" .. raw .. "'")
	return true
end

local function backup_create()
	local storage_copy = storage:to_table()
	local json_dump = minetest.write_json(storage_copy)

	if json_dump == nil then
		log_error("backup_create", "failed to create json string")
		return false
	end

	local filename = "archtec_playerdata_"  .. os.date("!%Y-%m-%d_%H:%M:%S", os.time()) .. ".txt" -- 2024-03-23_20:14:10
	local success = minetest.safe_file_write(datadir .. filename, json_dump)

	if not success then
		log_error("backup_create", "couldn't write backup file - unknown engine error")
		return false
	end

	local backup_size = math.floor(#json_dump / 1024) -- 1 KiB = 1024 Bytes

	log_action("backup_create", "created backup file " .. filename .. "; file is " .. backup_size .. " KiB big")
	return true
end

local function backup_restore(filename)
	local file = io.open(datadir .. filename, "r")

	if file == nil then
		log_error("backup_restore", "couldn't open backup file '" .. filename .. "'")
		return false
	end

	local raw = file:read("*all")
	-- tbd: do this

	--storage:from_table()
end

local function run_upgrades()
end

minetest.register_on_mods_loaded(function()
	if not minetest.mkdir(datadir) then
		error("[archtec_playerdata] Failed to create datadir directory '" .. datadir .. "'!")
	end

	-- Database maintenance procedure
	log_action("setup", "starting database maintenance procedure")
	backup_create()
	run_upgrades()
end)

-- Register key
function archtec_playerdata.register_key(key_name, key_type, default_value)
	if system.mode ~= "startup" then
		api_error("register_key", "tried to register '" .. key_name .. "' after startup")
	end
	if system.keys[key_name] then
		api_error("register_key", "'key_name' is already registered")
	end

	if type(key_name) ~= "string" then
		api_error("register_key", "'key_name' must be 'string'")
	end
	if not system.types[key_type] then
		api_error("register_key", "unsupported type for 'key_type'")
	end
	if not system.types[type(default_value)] then
		api_error("register_key", "unsupported type for 'default_value'")
	end

	system.keys[key_name] = {key_type = key_type, default_value = default_value}
	log_debug("register_key", "registered key '" .. key_name .. "' with 'type=" .. key_type .. "' and 'default_value=" .. default_value .. "'")
end

-- Get default_value of key
function archtec_playerdata.get_default(key_name)
	local key = system.keys[key_name]
	if key then
		return key.default_value
	end
	log_debug("get_default", "key '" .. key_name .. "' does not exist")
end

-- Get value of key
function archtec_playerdata.get(player_name, key_name)
	if not valid_player(player_name) then
		return
	end
end