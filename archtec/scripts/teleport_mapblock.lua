-- Code based on builtin/game/chat.lua
local S = core.get_translator("__builtin")

-- Teleports player <name> to <p> if possible
local function teleport_to_pos(name, p)
	-- Middle of mapblock
	p = vector.floor(p)
	local pos = vector.add(vector.multiply(p, 16), 7.5)

	local lm = 31007 -- equals MAX_MAP_GENERATION_LIMIT in C++
	if pos.x < -lm or pos.x > lm or pos.y < -lm or pos.y > lm
			or pos.z < -lm or pos.z > lm then
		return false, S("Cannot teleport out of map bounds!")
	end

	local teleportee = core.get_player_by_name(name)
	if not teleportee then
		return false, S("Cannot get player with name @1.", name)
	end
	if teleportee:get_attach() then
		return false, S("Cannot teleport, @1 " ..
			"is attached to an object!", name)
	end
	teleportee:set_pos(pos)
	return true, S("Teleporting @1 to @2. (Mapblock @3)", name, core.pos_to_string(pos, 1), core.pos_to_string(p))
end

core.register_chatcommand("tp_mapblock", {
	params = S("<X>,<Y>,<Z> | <name> <X>,<Y>,<Z>"),
	description = S("Teleport to position of mapblock"),
	privs = {teleport=true},
	func = function(name, param)
		local p = {}
		p.x, p.y, p.z = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		p = vector.apply(p, tonumber)
		if p.x and p.y and p.z then
			return teleport_to_pos(name, p)
		end

		local has_bring_priv = core.check_player_privs(name, {bring=true})
		local missing_bring_msg = S("You don't have permission to teleport " ..
			"other players (missing privilege: @1).", "bring")

		local teleportee_name
		teleportee_name, p.x, p.y, p.z = param:match(
				"^([^ ]+) +([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		p = vector.apply(p, tonumber)
		if teleportee_name and p.x and p.y and p.z then
			if not has_bring_priv then
				return false, missing_bring_msg
			end
			return teleport_to_pos(teleportee_name, p)
		end

		return false
	end,
})
