local function l(t)
	if type(t) ~= "table" then
		return 0
	end
	return archtec.count_keys(t)
end

minetest.after(5, function()
	minetest.log("action", "Registered privileges: " .. l(minetest.registered_privileges))
	minetest.log("action", "Registered chat commands: " .. l(minetest.registered_chatcommands))
	minetest.log("action", "Registered nodes: " .. l(minetest.registered_nodes))
	minetest.log("action", "Registered items: " .. l(minetest.registered_items))
	minetest.log("action", "Registered craftitems: " .. l(minetest.registered_craftitems))
	minetest.log("action", "Registered tools: " .. l(minetest.registered_tools))
	minetest.log("action", "Registered entities: " .. l(minetest.registered_entities))
	minetest.log("action", "Registered LBMs: " .. l(minetest.registered_lbms))
	minetest.log("action", "Registered ABMs: " .. l(minetest.registered_abms))
	minetest.log("action", "Registered ores: " .. l(minetest.registered_ores))
	minetest.log("action", "Registered biomes: " .. l(minetest.registered_biomes))
	minetest.log("action", "Registered decorations: " .. l(minetest.registered_decorations))
	minetest.log("action", "Registered schematics: " .. l(minetest.registered_schematics))
	minetest.log("action", "Registered aliases: " .. l(minetest.registered_aliases))
end)
