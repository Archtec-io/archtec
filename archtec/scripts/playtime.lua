local current_playtime = {}
archtec_playerdata.register_key("playtime", "number", 0)
archtec_playerdata.register_key("first_join", "number", 0)
archtec_playerdata.register_key("join_count", "number", 0)

local months = {Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12}
local function string_to_timestamp(s)
	local p = "(%a+) (%a+)(%s+)(%d+) (%d+):(%d+):(%d+) (%d+)"
	local _, month, _, day, hour, min, sec, year = s:match(p)
	month = months[month]
	local offset = os.time() - os.time(os.date("!*t"))
	return(os.time({day = day, month = month, year = year, hour = hour, min = min, sec = sec}) + offset)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	current_playtime[name] = os.time()

	archtec_playerdata.mod(name, "join_count", 1)

	-- Set first join date
	if archtec_playerdata.get(name, "first_join") == 0 then -- Move legacy data
		local str = player:get_meta():get_string("archtec:joined")
		if str ~= "" then
			local int = string_to_timestamp(str)
			archtec_playerdata.set(name, "first_join", int)
			player:get_meta():set_string("archtec:joined", "")
			minetest.log("action", "[archtec] removed 'archtec:joined' meta of '" .. name .. "' (moved to archtec_playerdata)")
		else
			archtec_playerdata.set(name, "first_join", os.time())
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local playtime = os.time() - current_playtime[name]
	archtec_playerdata.mod(name, "playtime", playtime)
	current_playtime[name] = nil
end)