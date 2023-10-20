-- based on https://github.com/wsor4035/liquid_restriction

local S = archtec.S
minetest.register_privilege("adv_buckets", ("Able to use all liquids."))

local liquid_list = {
	"bucket:bucket_lava",
}

local hours = 50
archtec.adv_buckets_playtime = archtec.time.hours(hours) -- 50 h playtime

local function try_grant_lava_priv(name)
	local playtime = archtec_playerdata.get(name, "playtime")
	if playtime > archtec.adv_buckets_playtime then
		archtec.grant_priv(name, "adv_buckets")
		minetest.chat_send_player(name, minetest.colorize("#00BD00", S("[request_lava]") .. " " .. S("Congratulations! You have been granted the '@1' privilege", "adv_buckets")))
		notifyTeam("[request_lava] Granted '" .. name .. "' the 'adv_buckets' priv")
		return true
	else
		minetest.chat_send_player(name, minetest.colorize("#FF0000", S("[request_lava]") .. " " .. S("You don't have @1 hours (or more) playtime", hours)))
		return false
	end
end

-- reads list, overrides nodes, adding priv check
local function override()
	for liquidcount = 1, #liquid_list do
		-- checks if its a valid node/item
		if minetest.registered_items[liquid_list[liquidcount]] then
			-- get old on_place behavior
			local old_place = minetest.registered_items[liquid_list[liquidcount]].on_place or function() end

			-- override
			minetest.override_item(liquid_list[liquidcount], {
				on_place = function(itemstack, placer, pointed_thing)
					local pname = placer:get_player_name()

					if not minetest.check_player_privs(pname, "adv_buckets") then
						if try_grant_lava_priv(pname) and minetest.check_player_privs(pname, "adv_buckets") then -- double check
							return old_place(itemstack, placer, pointed_thing)
						else
							return
						end
					else
						return old_place(itemstack, placer, pointed_thing)
					end
				end,
			})
		end
	end
end

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if def.drawtype and (def.drawtype == "liquid" or def.drawtype == "flowingliquid")
		and minetest.get_item_group(name, "liquid_blacklist") == 0 then
			table.insert(liquid_list, name)
		end
	end

	override()
end)
