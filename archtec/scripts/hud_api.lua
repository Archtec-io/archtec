-- Bad code & concept, I don't recommend copying this
local states = {}

--[[
{
	hud_ids = {2662, 21211, 2762, 2831},
	huds = {
		1 = {bg_color = "#FF", icon = ".png", icon_scale = 3}
	}
}
]]--

local function render_huds(name, player)
	local state = states[name]
	for _, hud_id in ipairs(state.hud_ids) do
		player:hud_remove(hud_id)
	end

	local x_offset = -30
	for _, def in ipairs(state.huds) do
		if next(def) then -- check for empty table
			table.insert(state.hud_ids, player:hud_add({ -- Background
				[core.features.hud_def_type_field and "type" or "hud_elem_type"] = "image",
				position = {x = 1, y = 1},
				scale = {x = 1, y = 1},
				offset = {x = x_offset, y = -30},
				text = "ui_formbg_9_sliced.png^[colorize:" .. def.bg_color .. ":60",
			}))
			table.insert(state.hud_ids, player:hud_add({ -- Icon
				[core.features.hud_def_type_field and "type" or "hud_elem_type"] = "image",
				position = {x = 1, y = 1},
				scale = {x = def.icon_scale, y = def.icon_scale},
				offset = {x = x_offset, y = -30},
				text = def.icon,
			}))
			x_offset = x_offset - 60
		end
	end
end

function archtec.modify_hud(name, slot, def)
	local player = core.get_player_by_name(name)
	if states[name] == nil then
		states[name] = {hud_ids = {}, huds = {}}
	end

	-- Create lower slot IDs
	for idx = 1, slot do
		if not states[name].huds[idx] then
			states[name].huds[idx] = {}
		end
	end

	states[name].huds[slot] = def
	render_huds(name, player)
end
