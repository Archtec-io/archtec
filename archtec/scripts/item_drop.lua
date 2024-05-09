local pickup_gain = 0.4
local pickup_radius = 0.75
local pickup_age = 0.5

-- adds the item to the inventory and removes the object
local function collect_item(ent, pos, player)
	minetest.sound_play("item_drop_pickup", {
		pos = pos,
		gain = pickup_gain,
	}, true)
	ent:on_punch(player)
end

-- opt_get_ent gets the object's luaentity if it can be collected
local function opt_get_ent(object)
	if object:is_player() then
		return
	end
	local ent = object:get_luaentity()
	if not ent or ent.name ~= "__builtin:item" or (ent.dropped_by and ent.age < pickup_age) or ent.itemstring == "" then
		return
	end
	return ent
end

-- called for each player to possibly collect an item, returns true if so
local function pickupfunc(player)
	if player:get_hp() <= 0 then
		return
	end

	local pos = player:get_pos()
	pos.y = pos.y + 0.5
	local inv = player:get_inventory()

	local objectlist = minetest.get_objects_inside_radius(pos, pickup_radius)

	for i = 1, #objectlist do
		local object = objectlist[i]
		local ent = opt_get_ent(object)
		if ent then
			local item = ItemStack(ent.itemstring)
			if inv:room_for_item("main", item) then
				-- The item is near enough to pick it
				collect_item(ent, pos, player)
				-- Collect one item at a time to avoid the loud pop
				return true
			end
		end
	end
end

local function pickup_step()
	local got_item
	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if archtec_playerdata.get(name, "s_r_id") == true then
			got_item = got_item or pickupfunc(player)
		end
	end
	-- lower step if takeable item(s) were found
	local time
	if got_item then
		time = 0.05 -- next step
	else
		time = 0.4
	end
	minetest.after(time, pickup_step)
end
minetest.after(3.0, pickup_step)
