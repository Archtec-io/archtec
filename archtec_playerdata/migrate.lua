-- Script to migrate from archtec_playerdata v1 to v2

--[[
local file = io.open(core.get_worldpath() .. "/dump_legacy.txt", "r")
local raw = file:read("*all")
file:close()

local data = core.deserialize(raw).fields
print("===SERIALIZED DATA===")
print(dump(data))

local i = 0
for name, str in pairs(data) do
	data[name] = core.deserialize(str)
end
print("===DATA AS LUA TABLE===")
print(dump(data))

local new = {}
for name, user_table in pairs(data) do
	new["player_" .. name] = user_table
end

local json = core.write_json(new)
core.safe_file_write(core.get_worldpath() .. "/dump_v2.txt", json)
]]--
