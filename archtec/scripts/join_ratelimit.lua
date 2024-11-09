-- limits the amount of prejoins for an ip to 1/second
-- mitigates https://github.com/minetest/minetest/issues/11877 and https://github.com/minetest/minetest/issues/9498

local ratelimit = {}
local after = core.after
local LIMIT = 1

local function remove_entry(ip)
	ratelimit[ip] = nil
end

core.register_on_prejoinplayer(function(_, ip)
	if ratelimit[ip] then
		return "You are joining too fast, please try again"
	else
		ratelimit[ip] = true
		after(LIMIT, remove_entry, ip)
	end
end)
