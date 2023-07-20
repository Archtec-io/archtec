local function C(text)
	return minetest.colorize("#666", text)
end

minetest.register_chatcommand("network_info", {
	params = "<name>",
	description = "Get network information of player",
	privs = {staff = true},
	func = function(name, param)
		minetest.log("action", "[/network_info] executed by '" .. name .. "' with param '" .. (param or "") .. "'")
		local target = archtec.get_target(name, param)
		local info = minetest.get_player_information(target)
		if not info then
			minetest.chat_send_player(name, "Can't get player info.")
			return
		end
		local min_jitter = info.min_jitter or "?"
		local max_jitter = info.max_jitter or "?"
		local avg_jitter = info.avg_jitter or "?"
		local connection_uptime = info.connection_uptime or "?"
		local protocol_version = info.version_string or "?"
		local address = info.address or "?"
		local ip_version = info.ip_version or "?"
		local min_rtt = info.min_rtt or "?"
		local max_rtt = info.max_rtt or "?"
		local avg_rtt = info.avg_rtt or "?"
		minetest.chat_send_player(name, "Network info for player " .. C(target) .. " IP: " .. C(address) .. " IP-V: " .. C(ip_version) .. " Uptime: " .. C(connection_uptime) .. " Prot-V: " .. C(protocol_version) ..
			" Jitter-min: " .. C(min_jitter) .. " Jitter-max: " .. C(max_jitter) .. " Jitter-avg: " .. C(avg_jitter) .. " RTT-min: " .. C(min_rtt) .. " RTT-max: " .. C(max_rtt) .. " RTT-avg: " .. C(avg_rtt))
	end
})