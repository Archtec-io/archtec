local pairs_by_key = futil.table.pairs_by_key

local function count_object()
	local ret = {}
	local total = 0

	local all_objects = core.luaentities

	for _, entity in pairs(all_objects) do
		local name = (entity or {}).name
		if name then
			total = total + 1
			ret[name] = (ret[name] or 0) + 1
		end
	end

	local parts = {}
	local previous_mod
	local mod_total = 0
	local mod_items = 0

	for name, count in pairs_by_key(ret) do
		local mod = name:match("^([^:]+):")

		if mod and previous_mod and mod ~= previous_mod then
			if mod_items > 1 then
				table.insert(parts, ("%s total = %s"):format(previous_mod, mod_total))
			end
			table.insert(parts, "..............")
			mod_total = 0
			mod_items = 0
		end

		table.insert(parts, ("%s = %s"):format(name, count))
		mod_total = mod_total + count
		mod_items = mod_items + 1
		previous_mod = mod
	end

	if previous_mod then
		if mod_items > 1 then
			table.insert(parts, ("%s total = %s"):format(previous_mod, mod_total))
		end
		table.insert(parts, "..............")
	end

	table.insert(parts, ("total = %s"):format(total))

	return table.concat(parts, "\n")
end

core.register_chatcommand("count_objects", {
	description = "Get counts of all objects active on the server",
	privs = {staff = true},
	func = function(name)
		core.log("action", "[/count_objects] executed by '" .. name .. "'")
		core.chat_send_player(name, count_object())
	end
})
