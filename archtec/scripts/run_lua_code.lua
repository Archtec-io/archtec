local function runlua(code)
	local func, err = loadstring(code)
	if not func then -- Syntax error
		return err
	end
	local good, err2 = pcall(func)
	if not good then -- Runtime error
		return err2
	end
	return nil
end

core.register_chatcommand("lua", {
	params = "<code>",
	description = "Executes <code> as a Lua chunk in the global namespace",
	privs = {staff = true},
	func = function(name, param)
		local err = runlua(param)
		if err then
			core.chat_send_player(name, "-!- code error: " .. err)
			core.log("action", name .. " tried to execute " .. param)
		else
			core.chat_send_player(name, "-!- code successfully executed")
			core.log("action", name .. " executed " .. param)
		end
	end
})
