local S = archtec.S
archtec.adv_buckets_playtime = archtec.time.hours(50)

core.register_privilege("adv_buckets", S("Able to use all liquids"))

local liquid_list = {
	"bucket:bucket_lava",
}

local function try_grant_priv(name)
	local playtime = archtec_playerdata.get(name, "playtime")
	if playtime > archtec.adv_buckets_playtime then
		archtec.priv_grant(name, "adv_buckets")
		core.chat_send_player(name, core.colorize("#00BD00", S("Congratulations! You have been granted the '@1' privilege.", "adv_buckets")))
		archtec.notify_team("[adv_buckets] Granted '" .. name .. "' the 'adv_buckets' priv")
		return true
	else
		core.chat_send_player(name, core.colorize("#FF0000", S("You don't have @1 hours (or more) playtime.", archtec.adv_buckets_playtime / 3600)))
		return false
	end
end

-- reads list, overrides nodes, adding priv check
local function override()
	for liquidcount = 1, #liquid_list do
		if core.registered_items[liquid_list[liquidcount]] then
			local old_place = core.registered_items[liquid_list[liquidcount]].on_place or function() end

			core.override_item(liquid_list[liquidcount], {
				on_place = function(itemstack, placer, pointed_thing)
					local name = placer:get_player_name()
					if not core.get_player_privs(name).adv_buckets then
						if try_grant_priv(name) then
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

core.register_on_mods_loaded(function()
	for name, def in pairs(core.registered_nodes) do
		if def.drawtype and (def.drawtype == "liquid" or def.drawtype == "flowingliquid") and core.get_item_group(name, "liquid_blacklist") == 0 then
			table.insert(liquid_list, name)
		end
	end

	override()
end)
