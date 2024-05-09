-- Based on https://github.com/Uberi/Minetest-WorldEdit/blob/master/worldedit/code.lua
local function runlua(code, name)
	local factory, err = loadstring("return function(name, player, pos)\n" .. code .. "\nend")
	if not factory then -- Syntax error
		return err
	end
	local func = factory()
	local player, pos
	if name then
		player = minetest.get_player_by_name(name)
		if player then
			pos = vector.round(player:get_pos())
		end
	end
	local good, err2 = pcall(func, name, player, pos)
	if not good then -- Runtime error
		return tostring(err2)
	end
	return nil, dump(err2)
end

minetest.register_chatcommand("lua", {
	params = "<code>",
	description = "Executes <code> as a Lua chunk in the global namespace",
	privs = {staff = true},
	func = function(name, param)
		local err, ret = runlua(param)
		if err == nil then
			minetest.log("action", "[archtec] " .. name .. " executed " .. param)
			if ret ~= "nil" then
				minetest.chat_send_player(name, "-!- code successfully executed, returned '" .. ret .. "'")
			else
				minetest.chat_send_player(name, "-!- code successfully executed")
			end
		else
			minetest.log("action", "[archtec] " .. name .. " tried to execute " .. param)
			minetest.chat_send_player(name, "-!- code error: " .. err)
		end
	end,
})
