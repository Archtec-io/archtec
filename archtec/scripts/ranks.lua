local registered = {}

local function get_color(color)
	return minetest.rgba(color.r, color.g, color.b, color.a)
end

local function register(name, def)
	registered[name] = def
end

local function get_rank(player)
	if minetest.check_player_privs(player, "staff") then
		if minetest.check_player_privs(player, "server") then
			return "admin"
		end
		return "mod"
	end
end

local function update_nametag(player, remove)
	local rank = get_rank(player)
	if rank ~= nil then
		local name = player:get_player_name()
		local def = registered[rank]
		local color = get_color(def.color)
		local prefix = minetest.colorize(color, def.prefix) .. " "

		if player then
			player:set_nametag_attributes({
				text = prefix .. name,
			})
		end

		return true
	end
	if remove and rank == nil then
		local name = player:get_player_name()
		player:set_nametag_attributes({
			text = name,
			color = "#ffffff",
		})
	end
end

archtec.ranks_update_nametag = update_nametag

-- Assign/update rank on join player
minetest.register_on_joinplayer(function(player)
	if not player then return end
	update_nametag(player, false)
end)

register("admin", {
	prefix = "[Admin]",
	color = {a = 255, r = 230, g = 33, b = 23},
})

register("mod", {
	prefix = "[Mod]",
	color = {a = 255, r = 255, g = 83, b = 37},
})

minetest.register_chatcommand("ranks_reload", {
	description = "Reload staff ranks",
	privs = {staff = true},
	func = function(name)
		minetest.log("action", "[/ranks_reload] executed by '" .. name .. "'")
		for _, player in ipairs(minetest.get_connected_players()) do
			update_nametag(player, true)
		end
		minetest.chat_send_player(name, "Ranks reloaded")
	end
})