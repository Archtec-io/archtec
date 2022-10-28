stamina = {}

stamina.settings = {
	tick = 800, --time in seconds after that 1 saturation point is taken
	tick_min = 4, --stamina ticks won't reduce saturation below this level
	health_tick = 4, --time in seconds after player gets healed/damaged
	exhaust_dig = 3, --exhaustion for digging a nod
	exhaust_place = 1, --exhaustion for placing a node
	exhaust_lvl = 160, --exhaustion level at which saturation gets lowered
	heal = 1, --amount of HP a player gains per stamina.health_tick
	heal_lvl = 12, --minimum saturation needed for healing
	starve = 1, --amount of HP a player loses per stamina.health_tick
	starve_lvl = 3, --maximum stamina needed for starving
	visual_max = 20 --hunger points
}
local settings = stamina.settings

local attribute = {
	saturation = "stamina:level",
	exhaustion = "stamina:exhaustion",
}

local function is_player(player)
	return (minetest.is_player(player) and not player.is_fake_player)
end

local function set_player_attribute(player, key, value)
	if player.get_meta then
		local meta = player:get_meta()
		if meta and value == nil then
			meta:set_string(key, "")
		elseif meta then
			meta:set_string(key, tostring(value))
		end
	else
		player:set_attribute(key, value)
	end
end

local function get_player_attribute(player, key)
	if player.get_meta then
		local meta = player:get_meta()
		return meta and meta:get_string(key) or ""
	else
		return player:get_attribute(key)
	end
end

local hud_ids_by_player_name = {}

local function get_hud_id(player)
	return hud_ids_by_player_name[player:get_player_name()]
end

local function set_hud_id(player, hud_id)
	hud_ids_by_player_name[player:get_player_name()] = hud_id
end

--- SATURATION API ---
function stamina.get_saturation(player)
	return tonumber(get_player_attribute(player, attribute.saturation))
end

function stamina.set_saturation(player, level)
	set_player_attribute(player, attribute.saturation, level)
	player:hud_change(
		get_hud_id(player),
		"number",
		math.min(settings.visual_max, level)
	)
end

function stamina.update_saturation(player, level)
	local old = stamina.get_saturation(player)

	if level == old then  -- To suppress HUD update
		return
	end

	if old < settings.heal_lvl then
		return
	end

	stamina.set_saturation(player, level)
end

function stamina.change_saturation(player, change)
	if not is_player(player) or not change or change == 0 then
		return false
	end
	local level = stamina.get_saturation(player) + change
	level = math.max(level, 0)
	level = math.min(level, settings.visual_max)
	stamina.update_saturation(player, level)
	return true
end

--- EXHAUSTION API ---
stamina.exhaustion_reasons = {
	dig = "dig",
	place = "place",
}

function stamina.get_exhaustion(player)
	return tonumber(get_player_attribute(player, attribute.exhaustion))
end

function stamina.set_exhaustion(player, exhaustion)
	set_player_attribute(player, attribute.exhaustion, exhaustion)
end

function stamina.exhaust_player(player, change, cause)
	if not is_player(player) then
		return
	end

	local exhaustion = stamina.get_exhaustion(player) or 0

	exhaustion = exhaustion + change

	if exhaustion >= settings.exhaust_lvl then
		exhaustion = exhaustion - settings.exhaust_lvl
		stamina.change_saturation(player, -1)
	end

	stamina.set_exhaustion(player, exhaustion)
end

-- Time based stamina functions
local function stamina_tick()
	-- lower saturation by 1 point after settings.tick second(s)
	for _, player in ipairs(minetest.get_connected_players()) do
		local saturation = stamina.get_saturation(player)
		if saturation > settings.tick_min then
			stamina.update_saturation(player, saturation - 1)
		end
	end
end

local function health_tick()
	-- heal or damage player, depending on saturation
	for _, player in ipairs(minetest.get_connected_players()) do
		local air = player:get_breath() or 0
		local hp = player:get_hp()
		local saturation = stamina.get_saturation(player)
		if hp == 20 then
			return
		end
		-- don't heal if dead or drowninga
		local should_heal = (
			saturation >= settings.heal_lvl and
			saturation >= hp and
			hp > 0 and
			air > 0
		)
		-- or damage player by 1 hp if saturation is < 2 (of 20)
		local is_starving = (
			saturation < settings.starve_lvl and hp > 0
		)

		if should_heal then
			player:set_hp(hp + settings.heal)
			stamina.exhaust_player(player, settings.exhaust_lvl, stamina.exhaustion_reasons.heal)
		elseif is_starving then
			player:set_hp(hp - settings.starve)
		end
	end
end

local stamina_timer = 0
local health_timer = 0

local function stamina_globaltimer(dtime)
	stamina_timer = stamina_timer + dtime
	health_timer = health_timer + dtime

	if stamina_timer > settings.tick then
		stamina_timer = 0
		stamina_tick()
	end

	if health_timer > settings.health_tick then
		health_timer = 0
		health_tick()
	end
end

-- override minetest.do_item_eat() so we can redirect hp_change to stamina
stamina.core_item_eat = minetest.do_item_eat
function minetest.do_item_eat(hp_change, replace_with_item, itemstack, player, pointed_thing)
	for _, callback in ipairs(minetest.registered_on_item_eats) do
		local result = callback(hp_change, replace_with_item, itemstack, player, pointed_thing)
		if result then
			return result
		end
	end

	if not is_player(player) or not itemstack then
		return itemstack
	end

	local player_pos = player:get_pos()

	minetest.sound_play("hbhunger_eat_generic", {
		object = player,
		pos = player_pos,
		max_hear_distance = 16,
	}, true)

	if hp_change > 0 then
		stamina.change_saturation(player, hp_change)
		stamina.set_exhaustion(player, 0)
	end

	itemstack:take_item()

	if replace_with_item then
		if itemstack:is_empty() then
			itemstack:add_item(replace_with_item)
		else
			local inv = player:get_inventory()
			if inv:room_for_item("main", {name = replace_with_item}) then
				inv:add_item("main", replace_with_item)
			else
				local pos = player:get_pos()
				pos.y = math.floor(pos.y - 1.0)
				minetest.add_item(pos, replace_with_item)
			end
		end
	end

	return itemstack
end

minetest.register_on_joinplayer(function(player)
	local level = stamina.get_saturation(player) or settings.visual_max
	local id = player:hud_add({
		name = "stamina",
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		size = {x = 24, y = 24},
		text = "stamina_hud_fg.png",
		number = level,
		text2 = "stamina_hud_bg.png",
		item = settings.visual_max,
		alignment = {x = -1, y = -1},
		offset = {x = -266, y = -110},
		max = 0,
	})
	set_hud_id(player, id)
	stamina.set_saturation(player, level)
end)

minetest.register_on_leaveplayer(function(player)
	set_hud_id(player, nil)
end)

minetest.register_globalstep(stamina_globaltimer)

minetest.register_on_placenode(function(pos, oldnode, player, ext)
	stamina.exhaust_player(player, settings.exhaust_place, stamina.exhaustion_reasons.place)
end)

minetest.register_on_dignode(function(pos, oldnode, player, ext)
	stamina.exhaust_player(player, settings.exhaust_dig, stamina.exhaustion_reasons.dig)
end)

minetest.register_on_respawnplayer(function(player)
	stamina.update_saturation(player, settings.visual_max)
end)
