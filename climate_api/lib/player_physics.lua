local mod_player_monoids = minetest.get_modpath("player_monoids") ~= nil
local physics = {}

-- use player monoids if available
if mod_player_monoids then
	function physics.add(id, player, effect, value)
		player_monoids[effect]:add_change(player, value, id)
	end

	function physics.remove(id, player, effect)
		player_monoids[effect]:del_change(player, id)
	end
-- fallback to vanilla override as last resort
else
	local function apply_physics(player)
		local playername = player:get_player_name()
		local override = { speed = 1, jump = 1, gravity = 1 }
		for effect, modifiers in pairs(physics[playername]) do
			override[effect] = 1
			for _, modifier in pairs(modifiers) do
				override[effect] = override[effect] * modifier
			end
		end
		player:set_physics_override(override)
	end

	function physics.add(id, player, effect, value)
		local playername = player:get_player_name()
		if physics[playername] == nil then physics[playername] = {} end
		if physics[playername][effect] == nil then physics[playername][effect] = {} end
		physics[playername][effect][id] = value
		apply_physics(player)
	end

	function physics.remove(id, player, effect)
		local playername = player:get_player_name()
		if physics[playername] == nil then return end
		if physics[playername][effect] == nil then return end
		if physics[playername][effect][id] == nil then return end
		physics[playername][effect][id] = nil
		apply_physics(player)
	end

	minetest.register_on_leaveplayer(function(player)
		local playername = player:get_player_name()
		physics[playername] = nil
	end)
end

return physics