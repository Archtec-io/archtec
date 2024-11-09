local S = archtec.S

local function break_warning(itemstack, user, node, digparams)
	if not user then return itemstack end
	local name = user:get_player_name()
	local wdef = itemstack:get_definition()
	if not core.is_creative_enabled(name) then
		itemstack:add_wear(digparams.wear)
		if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
			core.sound_play(wdef.sound.breaks, {
				to_player = name,
				pos = node.pos,
				gain = 0.5
			}, true)
		end
	end
	if itemstack:get_wear() > 60135 and wdef.sound and wdef.sound.breaks then
		if archtec_playerdata.get(name, "s_tbw_show") then
			core.chat_send_player(name, core.colorize("#FF0000", S("Your tool is about to break!")))
			core.sound_play(wdef.sound.breaks, {
				to_player = name,
				gain = 2.0,
			}, true)
		end
	end
	return itemstack
end

local function blacklisted(tool)
	if string.sub(tool, 1, 8) == "3d_armor" or
		string.sub(tool, 1, 15) == "christmas_decor" or
		string.sub(tool, 1, 7) == "shields" or
		string.sub(tool, 1, 18) == "invisible_3d_armor" or
		string.sub(tool, 1, 17) == "unified_inventory" or
		string.sub(tool, 1, 17) == "invisible_shields" then return true
	end
	return false
end

core.register_on_mods_loaded(function()
	for _, tool in pairs(core.registered_tools) do
		if not blacklisted(tool.name) then
			if tool.on_use then
				local old_on_use = core.registered_tools[tool.name].on_use
				core.override_item(tool.name, {
					on_use = function(itemstack, user, pointed_thing)
						local wdef = itemstack:get_definition()
						if itemstack:get_wear() > 60135 and wdef.sound and wdef.sound.breaks then
							local name = user:get_player_name()
							if archtec_playerdata.get(name, "s_tbw_show") then
								core.chat_send_player(name, core.colorize("#FF0000", S("Your tool is about to break!")))
								core.sound_play(wdef.sound.breaks, {
									to_player = name,
									gain = 2.0,
								}, true)
							end
						end
						return old_on_use(itemstack, user, pointed_thing)
					end
				})
			elseif not tool.after_use then
				core.override_item(tool.name, {
					after_use = break_warning
				})
			end
		end
	end
end)
