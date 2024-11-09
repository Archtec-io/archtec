local function l(t)
	if type(t) ~= "table" then
		return 0
	end
	return archtec.count_keys(t)
end

core.after(5, function()
	core.log("action", "Registered privileges: "..l(core.registered_privileges))
	core.log("action", "Registered chat commands: "..l(core.registered_chatcommands))
	core.log("action", "Registered nodes: "..l(core.registered_nodes))
	core.log("action", "Registered items: "..l(core.registered_items))
	core.log("action", "Registered craftitems: "..l(core.registered_craftitems))
	core.log("action", "Registered tools: "..l(core.registered_tools))
	core.log("action", "Registered entities: "..l(core.registered_entities))
	core.log("action", "Registered LBMs: "..l(core.registered_lbms))
	core.log("action", "Registered ABMs: "..l(core.registered_abms))
	core.log("action", "Registered ores: "..l(core.registered_ores))
	core.log("action", "Registered biomes: "..l(core.registered_biomes))
	core.log("action", "Registered decorations: "..l(core.registered_decorations))
	core.log("action", "Registered schematics: "..l(core.registered_schematics))
	core.log("action", "Registered aliases: "..l(core.registered_aliases))
end)
