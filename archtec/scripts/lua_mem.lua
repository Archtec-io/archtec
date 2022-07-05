minetest.register_chatcommand("memory", {
    description = "Get Lua memory usage",
    privs = {server = true},
    func = function(name, param)
		minetest.chat_send_player(
            name,
            ("Lua is using %uMB"):format(collectgarbage("count") / 1024)
        )
    end
})