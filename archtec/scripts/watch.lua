local spectator_mode = {}
local sm = spectator_mode

-- cache of saved states indexed by player name
-- original_state["watcher"] = state
local original_state = {}

local function original_state_get(player)
	if not player or not player:is_player() then return end

	-- check cache
	local state = original_state[player:get_player_name()]
	if state then return state end

	-- fallback to player's meta
	return minetest.deserialize(player:get_meta():get_string("spectator_mode:state"))
end

local function original_state_set(player, state)
	if not player or not player:is_player() then return end

	-- save to cache
	original_state[player:get_player_name()] = state

	-- backup to player's meta
	player:get_meta():set_string("spectator_mode:state", minetest.serialize(state))
end

local function original_state_delete(player)
	if not player or not player:is_player() then return end
	-- remove from cache
	original_state[player:get_player_name()] = nil
	-- remove backup
	player:get_meta():set_string("spectator_mode:state", "")
end

-- can be overriden to manipulate new_hud_flags
-- flags are the current hud_flags of player
function spectator_mode.turn_off_hud_hook(player, flags, new_hud_flags)
	new_hud_flags.breathbar = flags.breathbar
	new_hud_flags.healthbar = flags.healthbar
end -- turn_off_hud_hook

-- this doesn't hide /postool hud, hunger bar and similar
local function turn_off_hud_flags(player)
	local flags = player:hud_get_flags()
	local new_hud_flags = {}
	for flag in pairs(flags) do
		new_hud_flags[flag] = false
	end
	sm.turn_off_hud_hook(player, flags, new_hud_flags)
	player:hud_set_flags(new_hud_flags)
end -- turn_off_hud_flags

-- called by the detach command '/unwatch'
-- called on logout if player is attached at that time
-- called before attaching to another player
local function detach(name_watcher)
	-- nothing to do
	if not player_api.player_attached[name_watcher] then return end

	local watcher = minetest.get_player_by_name(name_watcher)
	if not watcher then return end -- shouldn't ever happen

	watcher:set_detach()
	player_api.player_attached[name_watcher] = false
	watcher:set_eye_offset()

	local state = original_state_get(watcher)
	-- nothing else to do
	if not state then return end

	-- NOTE: older versions of MT/MC may not have this
	watcher:set_nametag_attributes({
		color = state.nametag.color,
		bgcolor = state.nametag.bgcolor
	})
	watcher:hud_set_flags(state.hud_flags)
	watcher:set_properties({
		visual_size = state.visual_size,
		makes_footstep_sound = state.makes_footstep_sound,
		collisionbox = state.collisionbox,
	})
	ranks.update_nametag(name_watcher)

	-- restore privs
	local privs = minetest.get_player_privs(name_watcher)
	privs.interact = state.priv_interact

	minetest.set_player_privs(name_watcher, privs)

	-- set_pos seems to be very unreliable
	-- this workaround helps though
	minetest.after(0.1, function()
		watcher:set_pos(state.pos)
		-- delete state only after actually moved.
		-- this helps re-attach after log-off/server crash
		original_state_delete(watcher)
	end)

	minetest.log("action", "[spectator_mode] '" .. name_watcher .. "' detached from '" .. state.target .. "'")
end -- detach

-- both players are online and all checks have been done when this
-- method is called
local function attach(name_watcher, name_target)

	-- detach from cart, horse, bike etc.
	detach(name_watcher)

	local watcher = minetest.get_player_by_name(name_watcher)
	local privs_watcher = minetest.get_player_privs(name_watcher)
	-- back up some attributes
	local properties = watcher:get_properties()
	local state = {
		collisionbox = properties.collisionbox,
		hud_flags = watcher:hud_get_flags(),
		makes_footstep_sound = properties.makes_footstep_sound,
		nametag = watcher:get_nametag_attributes(),
		pos = watcher:get_pos(),
		priv_interact = privs_watcher.interact,
		privs_extra = {},
		target = name_target,
		visual_size = properties.visual_size,
	}

	original_state_set(watcher, state)

	-- set some attributes
	turn_off_hud_flags(watcher)
	watcher:set_properties({
		visual_size = { x = 0, y = 0 },
		makes_footstep_sound = false,
		collisionbox = { 0 }, -- TODO: is this the proper/best way?
	})
	watcher:set_nametag_attributes({ color = { a = 0 }, bgcolor = { a = 0 } })
	local eye_pos = vector.new(0, -5, -20)
	watcher:set_eye_offset(eye_pos)
	-- make sure watcher can't interact
	privs_watcher.interact = nil
	minetest.set_player_privs(name_watcher, privs_watcher)
	-- and attach
	player_api.player_attached[name_watcher] = true
	local target = minetest.get_player_by_name(name_target)
	if type(target) ~= "userdata" then return end -- prevent crashes
	watcher:set_attach(target, "", eye_pos)
	minetest.log("action", "[spectator_mode] '" .. name_watcher .. "' attached to '" .. name_target .. "'")

end

-- called by '/watch' command
local function watch(name_watcher, name_target)
	if original_state[name_watcher] then
		return true, "You are currently watching '" .. original_state[name_watcher].target .. "'. Say '/unwatch' first."
	end
	if name_watcher == name_target then
		return true, "You may not watch yourself."
	end

	local target = minetest.get_player_by_name(name_target)
	if not target then
		return true, "Invalid target name '" .. name_target .. "'"
	end

	-- avoid infinite loops
	if original_state[name_target] then
		return true, "'" .. name_target .. "' is watching " .. original_state[name_target].target .. "'. You may not watch a watcher."
	end

	attach(name_watcher, name_target)
	return true, "Watching '" .. name_target .. "' at '" .. minetest.pos_to_string(vector.round(target:get_pos()))

end -- watch

local function unwatch(name_watcher)
	-- nothing to do
	if not player_api.player_attached[name_watcher] then
		return true, "You are not observing anybody."
	end

	detach(name_watcher)
	return true -- no message as that has been sent by detach()
end

local function on_joinplayer(watcher)
	local state = original_state_get(watcher)
	if not state then return end

	-- attempt to move to original state after log-off
	-- during attach or server crash
	local name_watcher = watcher:get_player_name()
	original_state[name_watcher] = state
	player_api.player_attached[name_watcher] = true
	detach(name_watcher)
end

local function on_leaveplayer(watcher)
	local name_watcher = watcher:get_player_name()
	-- detach before leaving
	detach(name_watcher)
	-- detach any that are watching this user
	local attached = {}
	for name, state in pairs(original_state) do
		if name_watcher == state.target then
			table.insert(attached, name)
		end
	end
	-- we use separate loop to avoid editing a
	-- hash while it's being looped
	for _, name in ipairs(attached) do
		detach(name)
	end
end

-- different servers may want different behaviour, they can
-- override this function
function spectator_mode.on_respawnplayer(watcher)
	local state = original_state_get(watcher)
	if not state then return end

	local name_target = state.target
	local name_watcher = watcher:get_player_name()
	player_api.player_attached[name_watcher] = true
	detach(name_watcher)
	minetest.after(4, attach, name_watcher, name_target)
	return true
end

minetest.register_chatcommand("watch", {
	params = "<target name>",
	description = "Watch a given player",
	privs = {staff = true},
	func = watch,
})

minetest.register_chatcommand("unwatch", {
	description = "Unwatch a player",
	privs = {staff = true},
	func = unwatch,
})

minetest.register_on_joinplayer(on_joinplayer)
minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_on_respawnplayer(spectator_mode.on_respawnplayer)
