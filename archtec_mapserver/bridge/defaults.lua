mapserver.bridge.add_defaults = function(data)
	data.time = core.get_timeofday() * 24000
	data.uptime = core.get_server_uptime()
	data.max_lag = core.get_server_max_lag()
end
