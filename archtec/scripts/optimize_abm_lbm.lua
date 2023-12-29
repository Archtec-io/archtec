local function replace_groups(group)
	if group:sub(1, 6) ~= "group:" then -- Simple item
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

-- Override ABMs/LBMs
minetest.register_on_mods_loaded(function()
	for _, abm in ipairs(minetest.registered_abms) do
		abm.nodenames = replace(abm.nodenames)
		abm.neighbors = replace(abm.neighbors)
	end

	-- @reviewer LBMs need further testing
	--for _, lbm in ipairs(minetest.registered_lbms) do
	--	lbm.nodenames = replace(lbm.nodenames)
	--end
end)
