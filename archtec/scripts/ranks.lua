local registered = {
	admin = {prefix = "[Admin]", color = {a = 255, r = 230, g = 33, b = 23}, priv = "server",  prio = 3},
	mod = {prefix = "[Mod]", color = {a = 255, r = 255, g = 83, b = 37}, priv = "staff", prio = 2},
	builder = {prefix = "[Builder]", color = {a = 255, r = 0, g = 189, b = 0}, priv = "builder", prio = 1},
}

local function get_color(color)
	return core.rgba(color.r, color.g, color.b, color.a)
end

local function get_rank(player_name)
	local privs = core.get_player_privs(player_name)
	local rank = {prio = 0}
	for name, def in pairs(registered) do
		if privs[def.priv] and rank.prio < def.prio then
			rank = {name = name, prio = def.prio}
		end
	end
	return rank.name
end

local function update_nametag(player, remove)
	local name = player:get_player_name()
	local rank = get_rank(name)
	if rank ~= nil then
		local def = registered[rank]
		local color = get_color(def.color)
		local prefix = core.colorize(color, def.prefix) .. " "

		if player then
			player:set_nametag_attributes({
				text = prefix .. name,
			})
		end

		return true
	end
	if remove and rank == nil then
		player:set_nametag_attributes({
			text = name,
			color = "#ffffff",
		})
	end
end

-- Assign/update rank on join player
core.register_on_joinplayer(function(player)
	update_nametag(player, false)
end)

core.register_chatcommand("ranks_reload", {
	description = "Reload staff ranks",
	privs = {staff = true},
	func = function(name)
		core.log("action", "[/ranks_reload] executed by '" .. name .. "'")
		for _, player in ipairs(core.get_connected_players()) do
			update_nametag(player, true)
		end
		core.chat_send_player(name, "Ranks reloaded")
	end
})
