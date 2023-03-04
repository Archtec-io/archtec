local function runlua(code)
	local func, err = loadstring(code)
	if not func then  -- Syntax error
		return err
	end
	local good, err = pcall(func)
	if not good then  -- Runtime error
		return err
	end
	return nil
end

minetest.register_chatcommand("lua", {
	params = "<code>",
	description = "Executes <code> as a Lua chunk in the global namespace",
	privs = {staff = true},
	parse = function(param)
		return true, param
	end,
	func = function(name, param)
		local err = runlua(param)
		if err then
			minetest.chat_send_player(name, "-!- code error: "..err)
			minetest.log("action", name.." tried to execute "..param)
		else
			minetest.chat_send_player(name, "-!- code successfully executed")
			minetest.log("action", name.." executed "..param)
		end
	end,
})
