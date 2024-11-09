local basename = "mesecons_luacontroller:luacontroller"

for node, def in pairs(core.registered_nodes) do
	if node:sub(1, #basename) == basename then
		if def.on_receive_fields then
			local old_on_receive_fields = def.on_receive_fields
			def.on_receive_fields = function(pos, _, fields, sender)
				local code = dump(fields.code)
				local name = sender and sender:get_player_name() or "??"
				core.log("action", "[archtec] Lua controller programmed by " .. name .. " at " .. core.pos_to_string(pos) .. " with " .. code)
				return old_on_receive_fields(pos, _, fields, sender)
			end
		end
	end
end
