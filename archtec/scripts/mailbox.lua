local C = minetest.colorize
local S = archtec.S
local FS = function(...) return minetest.formspec_escape(S(...)) end

local mailbox = {}
local GIVER_LIST_LENGTH = 7
archtec_playerdata.register_key("mailbox", "string", "")

local function get_sign_pos(pos, mailbox_p2)
	local pos_sign = vector.copy(pos)
	pos_sign.y = pos_sign.y + 1

	if mailbox_p2 == 0 then
		pos_sign.z = pos_sign.z - 1
	elseif mailbox_p2 == 1 then
		pos_sign.x = pos_sign.x - 1
	elseif mailbox_p2 == 2 then
		pos_sign.z = pos_sign.z + 1
	elseif mailbox_p2 == 3 then
		pos_sign.x = pos_sign.x + 1
	else
		return -- should not happen, no sign
	end

	return pos_sign
end

local function get_img(img)
	if not img then return end
	local img_name = img:match("(.*)%.png")

	if img_name then
		return img_name .. ".png"
	end
end

local function img_col(stack)
	local def = minetest.registered_items[stack]
	if not def then
		return ""
	end

	if def.inventory_image ~= "" then
		local img = get_img(def.inventory_image)
		if img then
			return img
		end
	end

	if def.tiles then
		local tile, img = def.tiles[1]
		if type(tile) == "table" then
			img = get_img(tile.name)
		elseif type(tile) == "string" then
			img = get_img(tile)
		end

		if img then
			return img
		end
	end

	return ""
end

local function can_modify_mailbox(owner, name)
	return owner == name or minetest.get_player_privs(name).staff
end

function mailbox.get_formspec(pos, owner, fs_type)
	local is_letterbox = "false"
	if minetest.get_node(pos).name == "mailbox:letterbox" then
		is_letterbox = "true"
	end
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z

	if fs_type == 1 then -- owner
		local meta = minetest.get_meta(pos)
		local giver, img = "", ""

		for i = 1, GIVER_LIST_LENGTH do
			local giving = meta:get_string("giver" .. i)
			if giving ~= "" then
				local stack = meta:get_string("stack" .. i)
				local giver_name = giving:sub(1,12)
				local stack_name = stack:match("[%w_:]+")
				local stack_count = stack:match("%s(%d+)") or 1

				-- List of donors. A line looks like this:
				--    <donor name> <item icon> × <item count>
				giver = giver .. "#FFFF00," .. giver_name .. "," .. i ..
					-- Times a certain item count; used for the mailbox donor list
					",#FFFFFF," .. FS("× @1", stack_count) .. ","

				img = img .. i .. "=" ..
					img_col(stack_name) .. "^\\[resize:16x16,"
			end
		end

		return "size[9.5,9]" .. default.get_hotbar_bg(0.75, 5.25) ..
			"button_exit[0,-0.2;2,1;unrent;" .. FS("Unrent") .. "]" ..
			"checkbox[2.5,-0.2;books_only;" .. FS("Only allow written books") .. ";" .. is_letterbox .. "]" ..
			"label[6,0;" .. FS("Last donators") .. "]" ..
			[[ box[6,0.72;3.3,3.9;#555555]
			listring[current_player;main]
			list[current_player;main;0.75,5.25;8,4;]
			tableoptions[background=#00000000;highlight=#00000000;border=false] ]] ..
			"tablecolumns[color;text;image," .. img .. "0;color;text]" ..
			"table[6,0.75;3.3,4;givers;" .. giver .. "]" ..
			"list[nodemeta:" .. spos .. ";mailbox;0,0.75;6,4;]" ..
			"listring[nodemeta:" .. spos .. ";mailbox]"
	else
		return "size[8,5.25]" .. default.get_hotbar_bg(0, 1.5) ..
			"label[0,0;" .. FS("Send your goods to\n@1", C("#FFFF00", owner)) .. "]" ..
			"list[nodemeta:" .. spos .. ";drop;3.5,0;1,1;]" ..
			"listring[nodemeta:" .. spos .. ";drop]" ..
			"listring[current_player;main]" ..
			"list[current_player;main;0,1.5;8,4;]"
	end
end

function mailbox.unrent(pos, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	if can_modify_mailbox(meta:get_string("owner"), name) then
		local node = minetest.get_node(pos)
		node.name = "mailbox:mailbox_free"
		minetest.swap_node(pos, node)
		mailbox.after_place_free(pos, player)
		archtec_playerdata.set(name, "mailbox", "")

		-- Remove sign
		local pos_sign = get_sign_pos(pos, node.param2)

		if pos_sign and minetest.get_node(pos_sign).name == "basic_signs:sign_wall_steel_white_black" then
			signs_lib.update_sign(pos_sign, {text = ""})
		end
	end
end

function mailbox.switch_mode(pos, player)
	local meta = minetest.get_meta(pos)
	if can_modify_mailbox(meta:get_string("owner"), player:get_player_name()) then
		local node = minetest.get_node(pos)
		if node.name == "mailbox:mailbox" then
			node.name = "mailbox:letterbox"
			minetest.swap_node(pos, node)
		else
			node.name = "mailbox:mailbox"
			minetest.swap_node(pos, node)
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formname:match("mailbox:mailbox_") then
		return
	end

	if fields.unrent then
		local pos = minetest.string_to_pos(formname:sub(17))
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if inv:is_empty("mailbox") then
			mailbox.unrent(pos, player)
		else
			minetest.chat_send_player(player:get_player_name(), C("#FF0000", S("Your mailbox is not empty!")))
		end
	end

	if fields.books_only then
		local pos = minetest.string_to_pos(formname:sub(17))
		mailbox.switch_mode(pos, player)
	end

	return true
end)

function mailbox.on_place(itemstack, placer, pointed_thing) -- can't be placed, place a free mailbox instead
	return
end

function mailbox.after_place_node(pos, placer)
	local meta = minetest.get_meta(pos)
	local name = placer:get_player_name()

	meta:set_string("owner", name)
	meta:set_string("infotext", S("@1's Mailbox", name))
	archtec_playerdata.set(name, "mailbox", minetest.pos_to_string(pos))

	local inv = meta:get_inventory()
	inv:set_size("mailbox", 6 * 4)
	inv:set_size("drop", 1)

	-- Place sign w/ name
	local node = minetest.get_node(pos)
	local pos_sign = get_sign_pos(pos, node.param2)
	local prev_node_name = minetest.get_node(pos_sign).name

	if pos_sign and (prev_node_name == "air" or prev_node_name == "basic_signs:sign_wall_steel_white_black") then
		local meta_sign = minetest.get_meta(pos_sign)

		minetest.set_node(pos_sign, {name = "basic_signs:sign_wall_steel_white_black", param2 = node.param2})
		meta_sign:set_int("widefont", 1)
		signs_lib.update_sign(pos_sign, {text = "\n\n" .. name})
	end
end

function mailbox.on_rightclick_free(pos, _, clicker)
	local name = clicker:get_player_name()
	if archtec_playerdata.get(name, "mailbox") ~= "" then
		minetest.chat_send_player(name, C("#FF0000", S("You have already rented a mailbox at @1!", archtec_playerdata.get(name, "mailbox"))))
		return
	end

	local node = minetest.get_node(pos)
	node.name = "mailbox:mailbox"
	minetest.swap_node(pos, node)
	mailbox.after_place_node(pos, clicker)
end

function mailbox.after_place_free(pos, placer)
	local meta = minetest.get_meta(pos)

	meta:set_string("owner", "")
	meta:set_string("infotext", S("Free Mailbox, right-click to claim"))

	for i = 1, GIVER_LIST_LENGTH do
		meta:set_string("giver" .. i, "")
		meta:set_string("stack" .. i, "")
	end
end

function mailbox.on_rightclick(pos, _, clicker)
	local meta = minetest.get_meta(pos)
	local name = clicker:get_player_name()
	local owner = meta:get_string("owner")

	if name == owner or (minetest.get_player_privs(name).staff and clicker:get_player_control().aux1) then
		local spos = pos.x .. "," .. pos.y .. "," .. pos.z
		minetest.show_formspec(name, "mailbox:mailbox_" .. spos, mailbox.get_formspec(pos, owner, 1))
	else
		minetest.show_formspec(name, "mailbox:mailbox", mailbox.get_formspec(pos, owner, 0))
	end
end

function mailbox.can_dig(pos, player)
	local node = minetest.get_node(pos)
	return node.name == "mailbox:mailbox_free"
end

function mailbox.on_metadata_inventory_put(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	if listname == "drop" then
		local inv = meta:get_inventory()
		if inv:room_for_item("mailbox", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("mailbox", stack)

			for i = GIVER_LIST_LENGTH, 2, -1 do
				meta:set_string("giver" .. i, meta:get_string("giver" .. (i - 1)))
				meta:set_string("stack" .. i, meta:get_string("stack" .. (i - 1)))
			end

			meta:set_string("giver1", player:get_player_name())
			meta:set_string("stack1", stack:to_string())
		end
	end
end

function mailbox.allow_metadata_inventory_put(pos, listname, index, stack, player)
	local name = player:get_player_name()

	if listname == "drop" then
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")

		if archtec.ignore_check(name, owner) then
			archtec.ignore_msg("mailbox", name, owner)
			return 0
		end

		if minetest.get_node(pos).name == "mailbox:letterbox" and
			stack:get_name() ~= "default:book_written" then
			return 0
		end

		local inv = meta:get_inventory()
		if inv:room_for_item("mailbox", stack) then
			return -1
		else
			minetest.chat_send_player(name, C("#FF0000", S("Mailbox full!")))
			return 0
		end
	elseif listname == "mailbox" and minetest.get_player_privs(name).staff then -- staff can put things back
		return stack:get_count()
	end

	return 0
end

function mailbox.allow_metadata_inventory_take(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	if can_modify_mailbox(meta:get_string("owner"), player:get_player_name()) then
		return stack:get_count()
	end
	return 0
end

function mailbox.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	if can_modify_mailbox(meta:get_string("owner"), player:get_player_name()) then
		return count
	end
	return 0
end

minetest.register_node(":mailbox:mailbox", {
	description = S("Mailbox"),
	tiles = {
		"archtec_mailbox_top.png", "archtec_mailbox_bottom.png",
		"archtec_mailbox_side.png", "archtec_mailbox_side.png",
		"archtec_mailbox_side.png", "archtec_mailbox.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_defaults(),
	paramtype2 = "facedir",
	drop = "mailbox:mailbox_free",
	on_place = mailbox.on_place,
	after_place_node = mailbox.after_place_node,
	on_rightclick = mailbox.on_rightclick,
	can_dig = mailbox.can_dig,
	on_metadata_inventory_put = mailbox.on_metadata_inventory_put,
	allow_metadata_inventory_put = mailbox.allow_metadata_inventory_put,
	allow_metadata_inventory_take = mailbox.allow_metadata_inventory_take,
	allow_metadata_inventory_move = mailbox.allow_metadata_inventory_move,
})

minetest.register_node(":mailbox:mailbox_free", {
	description = S("Mailbox for Rent"),
	tiles = {
		"archtec_mailbox_free_top.png", "archtec_mailbox_free_bottom.png",
		"archtec_mailbox_free_side.png", "archtec_mailbox_free_side.png",
		"archtec_mailbox_free_side.png", "archtec_mailbox_free.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_defaults(),
	paramtype2 = "facedir",
	after_place_node = mailbox.after_place_free,
	on_rightclick = mailbox.on_rightclick_free,
	can_dig = mailbox.can_dig,
})

minetest.register_node(":mailbox:letterbox", {
	tiles = {
		"archtec_letterbox_top.png", "archtec_letterbox_bottom.png",
		"archtec_letterbox_side.png", "archtec_letterbox_side.png",
		"archtec_letterbox_side.png", "archtec_letterbox.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_defaults(),
	paramtype2 = "facedir",
	drop = "mailbox:mailbox_free",
	after_place_node = mailbox.after_place_node,
	on_rightclick = mailbox.on_rightclick,
	can_dig = mailbox.can_dig,
	on_metadata_inventory_put = mailbox.on_metadata_inventory_put,
	allow_metadata_inventory_put = mailbox.allow_metadata_inventory_put,
	allow_metadata_inventory_take = mailbox.allow_metadata_inventory_take,
	allow_metadata_inventory_move = mailbox.allow_metadata_inventory_move,
})
