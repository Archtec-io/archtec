local get_us_time = minetest.get_us_time
local metric = monitoring.counter("lbm_count", "number of lbm calls")
local metric_time = monitoring.counter("lbm_time", "time usage in microseconds for lbm calls")

local metric_time_max = monitoring.gauge(
	"lbm_time_max",
	"max time usage in microseconds for lbm calls",
	{autoflush = true}
)

minetest.register_on_mods_loaded(function()
	for _, lbm in ipairs(minetest.registered_lbms) do
		local old_action = lbm.action
		lbm.action = function(pos, node)
			metric.inc()
			local t0 = get_us_time()
			old_action(pos, node)
			local t1 = get_us_time()
			local diff = t1 - t0
			metric_time.inc(diff)
			metric_time_max.setmax(diff)
		end
	end
end)
