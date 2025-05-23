local S = archtec.S
local C = core.colorize
local state = {}

local function detach(name)
	local player = core.get_player_by_name(name)
	if not archtec.is_attached(player) then
		return
	end

	local props = state[name]
	if not state[name] then
		return
	end

	-- Detach from any object
	player:set_detach()
	player:set_eye_offset()
	player_api.player_attached[name] = false

	-- Restore nametag
	player:set_nametag_attributes({
		color = props.nametag_color,
		bgcolor = props.nametag_bgcolor,
	})

	-- Restore player props
	player:set_properties({
		visual_size = props.visual_size,
		makes_footstep_sound = props.makes_footstep_sound,
		collisionbox = props.collisionbox,
		show_on_minimap = true,
	})

	-- Reset pos
	core.after(0.1, function() -- delay=0 (next step) isn't reliable
		local player2 = core.get_player_by_name(name)
		if player2 then
			player2:set_pos(props.pos)
		end
	end)

	state[name] = nil
	core.log("action", "[archtec_watch] Detached '" .. name .. "' from '" .. props.target .. "'")
end

local function attach(name, target)
	-- Detach user from any kind of entity
	detach(name)

	-- Save some props for detach
	local player = core.get_player_by_name(name)
	local properties = player:get_properties()
	local nametage_attr = player:get_nametag_attributes()

	local props = {
		nametag_color = nametage_attr.color,
		nametag_bgcolor = nametage_attr.bgcolor,
		visual_size = properties.visual_size,
		makes_footstep_sound = properties.makes_footstep_sound,
		collisionbox = properties.collisionbox,
		target = target,
		pos = player:get_pos(),
	}
	state[name] = props

	-- Make player invisible
	player:set_properties({
		visual_size = {x = 0, y = 0},
		makes_footstep_sound = false,
		collisionbox = {0},
		show_on_minimap = false,
	})
	player:set_nametag_attributes({color = {a = 0}, bgcolor = {a = 0}})

	-- Attach player
	player_api.player_attached[name] = true

	local eye_pos = vector.new(0, -5, -20)
	local target_player = core.get_player_by_name(target)

	player:set_eye_offset(eye_pos)
	player:set_attach(target_player, "", eye_pos)

	core.log("action", "[archtec_watch] Attached '" .. name .. "' to '" .. target .. "'")
end

core.register_chatcommand("watch", {
	params = "<name>",
	description = "Watch a player",
	privs = {staff = true},
	func = function(name, param)
		core.log("action", "[/watch] executed by '" .. name .. "' with param '" .. param .. "'")
		local target = archtec.get_and_trim(param)

		if target == "" then
			core.chat_send_player(name, C("#FF0000", S("[watch] You must specify a player name!")))
			return
		end

		if state[name] ~= nil then
			core.chat_send_player(name, C("#FF0000", S("[watch] You are currently watching @1. Run '/unwatch' first!", state[name].target)))
			return
		end

		if archtec.is_attached(core.get_player_by_name(name)) then
			core.chat_send_player(name, C("#FF0000", S("[watch] You are currently attached to something!")))
			return
		end

		if name == target then
			core.chat_send_player(name, C("#FF0000", S("[watch] You can't watch yourself!")))
			return
		end

		if not archtec.is_online(target) then
			core.chat_send_player(name, C("#FF0000", S("[watch] Target '@1' is not online!", target)))
			return
		end

		if state[target] then
			core.chat_send_player(name, C("#FF0000", S("[watch] Target '@1' is watching '@2'!", target, state[target].target)))
			return
		end

		attach(name, target)
		core.chat_send_player(name, C("#00BD00", S("[watch] Watching @1.", target)))
	end
})

core.register_chatcommand("unwatch", {
	params = "",
	description = "Disable watch mode",
	privs = {staff = true},
	func = function(name)
		core.log("action", "[/unwatch] executed by '" .. name .. "'")

		if not state[name] then
			core.chat_send_player(name, C("#FF0000", S("[unwatch] You aren't watching anybody!")))
			return
		end

		local target = state[name].target
		detach(name)
		core.chat_send_player(name, C("#00BD00", S("[unwatch] Detached you from @1.", target)))
	end
})

core.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	-- Detach (watcher left)
	if state[name] then
		detach(name)
	end

	-- Detach (target left)
	for watcher, props in pairs(state) do
		if props.target == name then
			detach(watcher)
		end
	end

	state[name] = nil
end)

core.register_on_respawnplayer(function(player)
	local name = player:get_player_name()

	if state[name] then
		detach(name)
	end
end)

core.register_on_player_hpchange(function(player, hp_change, reason)
	local name = player:get_player_name()

	-- No damage for watchers
	if state[name] then
		return 0, true
	end
	return hp_change
end, true)
