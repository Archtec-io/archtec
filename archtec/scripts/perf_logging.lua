-- Slow ABM/NodeTimer/LBM logger
local get_us_time, P2S = core.get_us_time, core.pos_to_string

local abm_max_time = 20000 -- 20 ms
local nt_max_time = 20000 -- 20 ms
local lbm_max_time = 20000 -- 20 ms

core.register_on_mods_loaded(function()
	for _, abm in ipairs(core.registered_abms) do
		local old_action = abm.action
		abm.action = function(pos, node, active_object_count, active_object_count_wider)
			local t0 = get_us_time()
			old_action(pos, node, active_object_count, active_object_count_wider)
			local diff = get_us_time() - t0

			if diff > abm_max_time then
				core.log("action", "[archtec] ABM '" .. abm.label or "??" .. "', took " .. diff .. " us, pos " .. P2S(pos) .. ", node '" .. node.name .. "'")
			end
		end
	end

	for _, def in pairs(core.registered_nodes) do
		if def.on_timer then
			local old_action = def.on_timer
			def.on_timer = function(pos, elapsed)
				local t0 = get_us_time()
				local res = old_action(pos, elapsed)
				local diff = get_us_time() - t0

				if diff > nt_max_time then
					local node = core.get_node(pos)
					core.log("action", "[archtec] NodeTimer took " .. diff .. " us, pos " .. P2S(pos) .. ", node '" .. node.name .. "'")
				end

				return res
			end
		end
	end

	for _, lbm in ipairs(core.registered_lbms) do
		local old_action = lbm.action
		lbm.action = function(pos, node, dtime_s)
			local t0 = get_us_time()
			old_action(pos, node, dtime_s)
			local diff = get_us_time() - t0

			if diff > lbm_max_time then
				core.log("action", "[archtec] LBM '" .. lbm.label or "??" .. "', took " .. diff .. " us, pos " .. P2S(pos) .. ", node '" .. node.name .. "'")
			end
		end
	end
end)
