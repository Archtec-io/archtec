local function tableLength(T)
	local count = 0
	if type(T) == "table" then
		for _ in pairs(T) do count = count + 1 end
	end
	return count
end

minetest.after(5, function()
	minetest.log("action", "Registered privileges: "..tableLength(minetest.registered_privileges))
	minetest.log("action", "Registered chat commands: "..tableLength(minetest.registered_chatcommands))
	minetest.log("action", "Registered nodes: "..tableLength(minetest.registered_nodes))
	minetest.log("action", "Registered items: "..tableLength(minetest.registered_items))
	minetest.log("action", "Registered craft items: "..tableLength(minetest.registered_craftitems))
	minetest.log("action", "Registered tools: "..tableLength(minetest.registered_tools))
	minetest.log("action", "Registered entities: "..tableLength(minetest.registered_entities))
	minetest.log("action", "Registered LBMs: "..tableLength(minetest.registered_lbms))
	minetest.log("action", "Registered ABMs: "..tableLength(minetest.registered_abms))
	minetest.log("action", "Registered ores: "..tableLength(minetest.registered_ores))
	minetest.log("action", "Registered biomes: "..tableLength(minetest.registered_biomes))
	minetest.log("action", "Registered decorations: "..tableLength(minetest.registered_decorations))
	minetest.log("action", "Registered schematics: "..tableLength(minetest.registered_schematics))
	minetest.log("action", "Registered aliases: "..tableLength(minetest.registered_aliases))
end)