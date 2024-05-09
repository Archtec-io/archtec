archtec_teleport = {
	tpr = {},
	tp2me = {},
}

local S = minetest.get_translator("archtec_teleport")
local C = minetest.colorize

local timeout = archtec.time.minutes(1)
local range = 1

-- Helper to find a free and safe position
local vectors = {}

do
	for x = -range, range do
		for y = -range, range do
			for z = -range, range do
				if not (x == 0 and z == 0) then -- ignore places higher/lower the player pos
					vectors[#vectors + 1] = {x = x, y = y, z = z}
				end
			end
		end
	end
end

local function find_safe_pos(input_pos)
	local ppos = vector.round(input_pos)

	for _, vec in ipairs(vectors) do
		local pos = vector.add(ppos, vec)
		local pos_up = vector.new(pos.x, pos.y + 1, pos.z)
		local pos_up_2 = vector.new(pos.x, pos.y + 2, pos.z)

		local def = minetest.registered_nodes[minetest.get_node(pos).name] or {}
		local node_up = minetest.get_node(pos_up).name
		local node_up_2 = minetest.get_node(pos_up_2).name

		if def.walkable and (def.liquidtype == nil or def.liquidtype == "none") then
			if node_up == "air" and node_up_2 == "air" then
				return pos_up
			end
		end
	end
end

-- Create tpr/tp2me
function archtec_teleport.tpr_create(name, target)
	minetest.chat_send_player(
		name,
		C("#FF8800", S("[tpr] Teleport request sent. It will timeout in @1 seconds.", timeout))
	)
	minetest.chat_send_player(
		target,
		C("#FF8800", S("[tpr] @1 is requesting to teleport to you. Run '/ok' to accept.", name))
	)

	local time = os.time()
	archtec_teleport.tpr[target] = {name = name, created = time}

	minetest.after(timeout, function()
		if
			archtec_teleport.tpr[target]
			and archtec_teleport.tpr[target].name == name
			and archtec_teleport.tpr[target].created == time
		then
			minetest.chat_send_player(name, C("#FF8800", S("[tpr] Your request to teleport to @1 timed-out.", target)))
			minetest.chat_send_player(target, C("#FF8800", S("[tpr] Teleport request by @1 timed-out.", name)))

			archtec_teleport.tpr[target] = nil
		end
	end)
end

function archtec_teleport.tp2me_create(name, target)
	minetest.chat_send_player(
		name,
		C("#FF8800", S("[tp2me] Teleport request sent. It will timeout in @1 seconds.", timeout))
	)
	minetest.chat_send_player(
		target,
		C("#FF8800", S("[tp2me] @1 is requesting to teleport you to them. Run '/ok' to accept.", name))
	)

	local time = os.time()
	archtec_teleport.tp2me[target] = {name = name, created = time}

	minetest.after(timeout, function()
		if
			archtec_teleport.tp2me[target]
			and archtec_teleport.tp2me[target].name == name
			and archtec_teleport.tp2me[target].created == time
		then
			minetest.chat_send_player(
				name,
				C("#FF8800", S("[tp2me] Your request to teleport @1 to you timed-out.", target))
			)
			minetest.chat_send_player(
				target,
				C("#FF8800", S("[tp2me] Teleport request to teleport you to @1 timed-out.", name))
			)

			archtec_teleport.tp2me[target] = nil
		end
	end)
end

-- Accept tpr/tp2me
function archtec_teleport.tpr_accept(name, target) -- name gets teleported; target /ok
	local player = minetest.get_player_by_name(name)
	local target_obj = minetest.get_player_by_name(target)

	if not player or not target_obj then
		minetest.chat_send_player(target, C("#FF0000", S("[tpr] @1 is currently not online!", name)))
		return
	end

	if player_api.player_attached[target] then
		minetest.chat_send_player(
			target,
			C("#FF0000", S("[tpr] You can't accept the teleport request since you're attached to something!"))
		)
		return
	end

	if player_api.player_attached[name] or archtec.physics_locked(player) then
		minetest.chat_send_player(
			name,
			C("#FF0000", S("[tpr] @1 tried to accept the teleport request but you are attached to something!", target))
		)
		minetest.chat_send_player(
			target,
			C("#FF0000", S("[tpr] @1 is currently attached to something. You can't accept the teleport request!", name))
		)
		return
	end

	local pos = find_safe_pos(target_obj:get_pos())

	if not pos then
		minetest.chat_send_player(
			name,
			C("#FF0000", S("[tpr] @1 tried to accept the teleport request but isn't at a safe spot!", target))
		)
		minetest.chat_send_player(
			target,
			C("#FF0000", S("[tpr] You can't accept the teleport request because you aren't at a safe spot!"))
		)
		return
	end

	minetest.sound_play("archtec_teleport_warp", {to_player = name, gain = 0.5}, true)
	minetest.sound_play("archtec_teleport_warp", {to_player = target, gain = 0.5}, true)

	minetest.chat_send_player(name, C("#FF8800", S("[tpr] @1 accepted your request to teleport to them.", target)))
	minetest.chat_send_player(target, C("#FF8800", S("[tpr] You accepted @1's request to teleport to you.", name)))

	player:set_pos(pos)
	minetest.log(
		"action",
		"[archtec_teleport] '"
			.. target
			.. "' accepted a tpr by '"
			.. name
			.. "' ('"
			.. name
			.. "' gets teleported to '"
			.. target
			.. "')"
	)
	archtec_teleport.tpr[target] = nil
end

function archtec_teleport.tp2me_accept(name, target) -- name nothing; target /ok and gets teleported
	local player = minetest.get_player_by_name(name)
	local target_obj = minetest.get_player_by_name(target)

	if not player or not target_obj then
		minetest.chat_send_player(target, C("#FF0000", S("[tp2me] @1 is currently not online!", name)))
		return
	end

	if player_api.player_attached[target] or archtec.physics_locked(target_obj) then
		minetest.chat_send_player(
			target,
			C("#FF0000", S("[tp2me] You can't accept the teleport request since you're attached to something!"))
		)
		return
	end

	if player_api.player_attached[name] or archtec.physics_locked(player) then
		minetest.chat_send_player(
			name,
			C(
				"#FF0000",
				S("[tp2me] @1 tried to accept the teleport request but you are attached to something!", target)
			)
		)
		minetest.chat_send_player(
			target,
			C(
				"#FF0000",
				S("[tp2me] @1 is currently attached to something. You can't accept the teleport request!", name)
			)
		)
		return
	end

	local pos = find_safe_pos(player:get_pos())

	if not pos then
		minetest.chat_send_player(
			name,
			C("#FF0000", S("[tp2me] @1 tried to accept the teleport request but you aren't at a safe spot!", target))
		)
		minetest.chat_send_player(
			target,
			C("#FF0000", S("[tp2me] You can't accept the teleport request because @1 isn't at a safe spot!", name))
		)
		return
	end

	minetest.sound_play("archtec_teleport_warp", {to_player = name, gain = 0.5}, true)
	minetest.sound_play("archtec_teleport_warp", {to_player = target, gain = 0.5}, true)

	minetest.chat_send_player(
		name,
		C("#FF8800", S("[tp2me] @1 accepted your request to teleport them to you.", target))
	)
	minetest.chat_send_player(target, C("#FF8800", S("[tp2me] You accepted @1's request to teleport to them.", name)))

	target_obj:set_pos(pos)
	minetest.log(
		"action",
		"[archtec_teleport] '"
			.. target
			.. "' accepted a tp2me by '"
			.. name
			.. "' ('"
			.. target
			.. "' gets teleported to '"
			.. name
			.. "')"
	)
	archtec_teleport.tp2me[target] = nil
end

-- Chatcommands
minetest.register_chatcommand("tpr", {
	description = S("Request <name> to teleport you to them"),
	params = "<name>",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/tpr] executed by '" .. name .. "' with param '" .. param .. "'")
		local target = archtec.get_and_trim(param)

		if target == "" then
			minetest.chat_send_player(name, C("#FF0000", S("[tpr] You must specify a player name!")))
			return
		end

		if target == name then
			minetest.chat_send_player(name, C("#FF0000", S("[tpr] You can't teleport you to yourself!")))
			return
		end

		if not archtec.is_online(target) then
			minetest.chat_send_player(name, C("#FF0000", S("[tpr] Player @1 is currently not online!", target)))
			return
		end

		if archtec.ignore_check(name, target) then
			archtec.ignore_msg("tpr", name, target)
			return
		end

		if archtec_teleport.tpr[target] then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tpr] Sorry, there's already a teleport request for @1 running!", target))
			)
			return
		end

		if player_api.player_attached[name] or archtec.physics_locked(minetest.get_player_by_name(name)) then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tpr] You are attached so something, can't create teleport request!"))
			)
			return
		end

		archtec_teleport.tpr_create(name, target)
	end,
})

minetest.register_chatcommand("tp2me", {
	description = S("Request <name> to teleport to you"),
	params = "<name>",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/tp2me] executed by '" .. name .. "' with param '" .. param .. "'")
		local target = archtec.get_and_trim(param)

		if target == "" then
			minetest.chat_send_player(name, C("#FF0000", S("[tp2me] You must specify a player name!")))
			return
		end

		if target == name then
			minetest.chat_send_player(name, C("#FF0000", S("[tp2me] You can't teleport you to yourself!")))
			return
		end

		if not archtec.is_online(target) then
			minetest.chat_send_player(name, C("#FF0000", S("[tp2me] Player @1 is currently not online!", target)))
			return
		end

		if archtec.ignore_check(name, target) then
			archtec.ignore_msg("tp2me", name, target)
			return
		end

		if archtec_teleport.tp2me[target] then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tp2me] Sorry, there's already a teleport request for @1 running!", target))
			)
			return
		end

		if player_api.player_attached[name] or archtec.physics_locked(minetest.get_player_by_name(name)) then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tp2me] You are attached so something, can't create teleport request!"))
			)
			return
		end

		archtec_teleport.tp2me_create(name, target)
	end,
})

minetest.register_chatcommand("ok", {
	description = S("Accept a teleport request by another player"),
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/ok] executed by '" .. name .. "'")

		if not archtec_teleport.tpr[name] and not archtec_teleport.tp2me[name] then
			minetest.chat_send_player(
				name,
				C("#FF0000", S("[tpr] There is currently no teleport request which you could accept!"))
			)
			return
		end

		if archtec_teleport.tpr[name] then
			archtec_teleport.tpr_accept(archtec_teleport.tpr[name].name, name)
		elseif archtec_teleport.tp2me[name] then
			archtec_teleport.tp2me_accept(archtec_teleport.tp2me[name].name, name)
		end
	end,
})
