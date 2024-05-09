local C = minetest.colorize
local S = archtec.S
local FS = function(...)
	return minetest.formspec_escape(S(...))
end

local mailbox = {}
archtec_playerdata.register_key("mailbox", "string", "")

function mailbox.get_formspec(pos, owner, fs_type)
	local is_letterbox = "false"
	if minetest.get_node(pos).name == "mailbox:letterbox" then
		is_letterbox = "true"
	end
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z

	if fs_type == 1 then
		return "size[8,9.5]"
			.. default.get_hotbar_bg(0, 5.5)
			.. "checkbox[0,0;books_only;"
			.. FS("Only allow written books")
			.. ";"
			.. is_letterbox
			.. "]"
			.. "list[nodemeta:"
			.. spos
			.. ";mailbox;0,1;8,4;]"
			.. "listring[nodemeta:"
			.. spos
			.. ";mailbox]"
			.. "listring[current_player;main]"
			.. "list[current_player;main;0,5.5;8,4;]"
			.. "button_exit[6,0;2,1;unrent;"
			.. FS("Unrent")
			.. "]"
	else
		return "size[8,5.25]"
			.. default.get_hotbar_bg(0, 1.5)
			.. "label[0,0;"
			.. FS("Send your goods to\n@1", C("#FFFF00", owner))
			.. "]"
			.. "list[nodemeta:"
			.. spos
			.. ";drop;3.5,0;1,1;]"
			.. "listring[nodemeta:"
			.. spos
			.. ";drop]"
			.. "listring[current_player;main]"
			.. "list[current_player;main;0,1.5;8,4;]"
	end
end

function mailbox.unrent(pos, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	if meta:get_string("owner") == name then
		local node = minetest.get_node(pos)
		node.name = "mailbox:mailbox_free"
		minetest.swap_node(pos, node)
		mailbox.after_place_free(pos, player)
		archtec_playerdata.set(name, "mailbox", "")
	end
end

function mailbox.switch_mode(pos, player)
	local meta = minetest.get_meta(pos)
	if meta:get_string("owner") == player:get_player_name() then
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

function mailbox.on_place(itemstack, placer, pointed_thing) -- can't be placed, rent a free mailbox instead
	return
end

function mailbox.after_place_node(pos, placer)
	local meta = minetest.get_meta(pos)
	local name = placer:get_player_name()

	meta:set_string("owner", name)
	meta:set_string("infotext", S("@1's Mailbox", name))
	archtec_playerdata.set(name, "mailbox", minetest.pos_to_string(pos))

	local inv = meta:get_inventory()
	inv:set_size("mailbox", 8 * 4)
	inv:set_size("drop", 1)
end

function mailbox.on_rightclick_free(pos, _, clicker)
	local name = clicker:get_player_name()
	if archtec_playerdata.get(name, "mailbox") ~= "" then
		minetest.chat_send_player(
			name,
			C("#FF0000", S("You have already rented a mailbox at @1!", archtec_playerdata.get(name, "mailbox")))
		)
		return
	end

	local node = minetest.get_node(pos)
	node.name = "mailbox:mailbox"
	minetest.swap_node(pos, node)
	mailbox.after_place_node(pos, clicker)
end

function mailbox.after_place_free(pos, placer)
	local meta = minetest.get_meta(pos)

	meta:set_string("infotext", S("Free Mailbox, right-click to claim"))
end

function mailbox.on_rightclick(pos, _, clicker)
	local meta = minetest.get_meta(pos)
	local name = clicker:get_player_name()
	local owner = meta:get_string("owner")

	if name == owner then
		local spos = pos.x .. "," .. pos.y .. "," .. pos.z
		minetest.show_formspec(name, "mailbox:mailbox_" .. spos, mailbox.get_formspec(pos, owner, 1))
	else
		minetest.show_formspec(name, "mailbox:mailbox", mailbox.get_formspec(pos, owner, 0))
	end
end

function mailbox.can_dig(pos, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local name = player:get_player_name()
	local inv = meta:get_inventory()

	return inv:is_empty("mailbox") and name == owner
end

function mailbox.on_metadata_inventory_put(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	if listname == "drop" then
		local inv = meta:get_inventory()
		if inv:room_for_item("mailbox", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("mailbox", stack)
		end
	end
end

function mailbox.allow_metadata_inventory_put(pos, listname, index, stack, player)
	if listname == "drop" then
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local name = player:get_player_name()

		if archtec.ignore_check(name, owner) then
			archtec.ignore_msg("mailbox", name, owner)
			return 0
		end

		if minetest.get_node(pos).name == "mailbox:letterbox" and stack:get_name() ~= "default:book_written" then
			return 0
		end

		local inv = meta:get_inventory()
		if inv:room_for_item("mailbox", stack) then
			return -1
		else
			minetest.chat_send_player(name, C("#FF0000", S("Mailbox full!")))
			return 0
		end
	end
	return 0
end

function mailbox.allow_metadata_inventory_take(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()

	if meta:get_string("owner") == name then
		return stack:get_count()
	end
	return 0
end

function mailbox.allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()

	if meta:get_string("owner") == name then
		return count
	end
	return 0
end

minetest.register_node(":mailbox:mailbox", {
	description = S("Mailbox"),
	tiles = {
		"archtec_mailbox_top.png",
		"archtec_mailbox_bottom.png",
		"archtec_mailbox_side.png",
		"archtec_mailbox_side.png",
		"archtec_mailbox.png",
		"archtec_mailbox.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_defaults(),
	paramtype2 = "facedir",
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
		"archtec_mailbox_free_top.png",
		"archtec_mailbox_free_bottom.png",
		"archtec_mailbox_free_side.png",
		"archtec_mailbox_free_side.png",
		"archtec_mailbox_free.png",
		"archtec_mailbox_free.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_defaults(),
	paramtype2 = "facedir",
	drop = "mailbox:mailbox",
	after_place_node = mailbox.after_place_free,
	on_rightclick = mailbox.on_rightclick_free,
	can_dig = mailbox.can_dig,
})

minetest.register_node(":mailbox:letterbox", {
	tiles = {
		"archtec_letterbox_top.png",
		"archtec_letterbox_bottom.png",
		"archtec_letterbox_side.png",
		"archtec_letterbox_side.png",
		"archtec_letterbox.png",
		"archtec_letterbox.png",
	},
	groups = {cracky = 3, oddly_breakable_by_hand = 1, not_in_creative_inventory = 1},
	on_rotate = screwdriver.rotate_simple,
	sounds = default.node_sound_defaults(),
	paramtype2 = "facedir",
	drop = "mailbox:mailbox",
	after_place_node = mailbox.after_place_node,
	on_rightclick = mailbox.on_rightclick,
	can_dig = mailbox.can_dig,
	on_metadata_inventory_put = mailbox.on_metadata_inventory_put,
	allow_metadata_inventory_put = mailbox.allow_metadata_inventory_put,
	allow_metadata_inventory_take = mailbox.allow_metadata_inventory_take,
	allow_metadata_inventory_move = mailbox.allow_metadata_inventory_move,
})
