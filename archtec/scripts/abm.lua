local function replace_groups(group)
	if group:sub(1, 6) ~= "group:" then -- simple item
		return group
	end

	local matches = {}
	local groupname = group:sub(7, #group)
	for name, def in pairs(minetest.registered_nodes) do
		for g, _ in pairs(def.groups) do
			if g == groupname then
				table.insert(matches, name)
			end
		end
	end

	return matches
end

local function replace(input)
	if input == nil or input == "" or archtec.count_keys(input) == 0 then
		return input
	end

	local nodenames = {}

	if type(input) == "table" then
		for _, group in ipairs(input) do
			local new_nodenames = replace_groups(group)
			if type(new_nodenames) == "table" then
				table.insert_all(nodenames, new_nodenames)
			else
				table.insert(nodenames, new_nodenames)
			end
		end
	else
		local new_nodenames = replace_groups(input)
		if type(new_nodenames) == "table" then
			table.insert_all(nodenames, new_nodenames)
		else
			table.insert(nodenames, new_nodenames)
		end
	end

	return nodenames
end

-- override abms
minetest.register_on_mods_loaded(function()
	for _, ab in ipairs(minetest.registered_abms) do
		local label = ab.label or ""

		-- optimize group resolving
		ab.nodenames = replace(ab.nodenames)
		ab.neighbors = replace(ab.neighbors)

		-- modify spawn chances of mobs
		if label:sub(1, 12) == "mobs_animal:" then
			ab.chance = ab.chance * 0.75
		end

		if label:sub(1, 13) == "mobs_monster:" then
			ab.chance = ab.chance * 0.5
		end
	end
end)

-- Slow ABM/NodeTimer/LBM logger
local get_us_time, P2S = minetest.get_us_time, minetest.pos_to_string

local abm_max_time = 5000 -- 5 ms
local nt_max_time = 10000 -- 10 ms
local lbm_max_time = 10000 -- 10 ms

function archtec.abm_max_time(t)
	abm_max_time = t
end

function archtec.nt_max_time(t)
	nt_max_time = t
end

function archtec.lbm_max_time(t)
	lbm_max_time = t
end

local function inc_abm(label, diff, pos, nn)
	if diff > abm_max_time then
		minetest.log("action", "ABM '" .. label .. "', took '" .. diff .. "' us, pos '" .. P2S(pos) .. "', node '" .. nn .. "'")
	end
end

local function inc_nt(diff, pos)
	if diff > nt_max_time then
		local nn = minetest.get_node(pos).name
		minetest.log("action", "NodeTimer took '" .. diff .. "' us, pos '" .. P2S(pos) .. "', node '" .. nn .. "'")
	end
end

local function inc_lbm(label, diff, pos, nn)
	if diff > lbm_max_time then
		minetest.log("action", "LBM '" .. label .. "', took '" .. diff .. "' us, pos '" .. P2S(pos) .. "', node '" .. nn .. "'")
	end
end

minetest.register_on_mods_loaded(function()
	for _, abm in ipairs(minetest.registered_abms) do
		local old_action = abm.action
		abm.action = function(pos, node, active_object_count, active_object_count_wider)
			local t0 = get_us_time()
			old_action(pos, node, active_object_count, active_object_count_wider)
			local diff = get_us_time() - t0
			inc_abm(abm.label or "??", diff, pos, node.name)
		end
	end

	for _, def in pairs(minetest.registered_nodes) do
		if def.on_timer then
			local old_action = def.on_timer
			def.on_timer = function(pos, elapsed)
				local t0 = get_us_time()
				local res = old_action(pos, elapsed)
				local diff = get_us_time() - t0
				inc_nt(diff, pos)
				return res
			end
		end
	end

	for _, lbm in ipairs(minetest.registered_lbms) do
		local old_action = lbm.action
		lbm.action = function(pos, node, dtime_s)
			local t0 = get_us_time()
			old_action(pos, node, dtime_s)
			local diff = get_us_time() - t0
			inc_lbm(lbm.label or "??", diff, pos, node.name)
		end
	end
end)
