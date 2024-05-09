local S = archtec.S
local FS = function(...)
	return minetest.formspec_escape(S(...))
end
local data = {}

local item_list = {
	"archtec:wood1",
	"archtec:wood2",
	"archtec:wood4",
	"archtec:acacia_wood1",
	"archtec:acacia_wood2",
	"archtec:acacia_wood4",
	"archtec:pine_wood1",
	"archtec:pine_wood2",
	"archtec:pine_wood4",
	"archtec:junglewood1",
	"archtec:junglewood2",
	"archtec:junglewood4",
	"archtec:aspen_wood1",
	"archtec:aspen_wood2",
	"archtec:aspen_wood4",
	"homedecor:fence_wrought_iron_2_slow",
}

for i, item in ipairs(item_list) do
	item_list[i] = item .. " 99"
end

local function create_inv(player_name)
	minetest.create_detached_inventory("archtec_creative_" .. player_name, {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			local name = player and player:get_player_name() or ""
			if not minetest.get_player_privs(name).builder or to_list == "main" then
				return 0
			end
			return count
		end,
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			local name = player and player:get_player_name() or ""
			if not minetest.get_player_privs(name).builder then
				return 0
			end
			return -1
		end,
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player) end,
		on_take = function(inv, listname, index, stack, player)
			if stack and stack:get_count() > 0 then
				minetest.log(
					"action",
					"[archtec] " .. player_name .. " takes " .. stack:get_name() .. " from builder creative inventory"
				)
			end
		end,
	}, player_name)

	local inv = minetest.get_inventory({type = "detached", name = "archtec_creative_" .. player_name})
	inv:set_size("main", #item_list)
	inv:set_list("main", item_list)
	data[player_name] = true
end

local function show_inv_formspec(name)
	if not data[name] then
		create_inv(name)
	end

	local formspec = {
		"formspec_version[3]",
		"size[10.4,9.2s]",
		"box[0.3,0.3;9.8,0.5;#c6e8ff]",
		"label[0.4,0.55;" .. FS("Creative inventory for builders - @1 items", #item_list) .. "]",
		"list[detached:archtec_creative_" .. name .. ";main;0.3,1.1;8,4;]",
		default.get_hotbar_bg(0.3, 4),
		"list[current_player;main;0.3,4;8,4;]",
	}

	minetest.show_formspec(name, "archtec:creative_inv", table.concat(formspec))
end

minetest.register_chatcommand("bci", {
	params = "",
	description = "Creative inventory for builders",
	privs = {builder = true},
	func = function(name, param)
		minetest.log("action", "[/bci] executed by '" .. name .. "'")
		show_inv_formspec(name)
	end,
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if data[name] then
		minetest.remove_detached_inventory("archtec_creative_" .. name)
		data[name] = nil
	end
end)
