archtec_chat = {
    users = {},
    channels = {}
}

archtec_chat.channel = dofile(minetest.get_modpath("archtec_chat") .. "/channels.lua")

archtec_chat.channel.create("main", "priv.staff", true)
archtec_chat.channel.create("staff", "priv.staff", true)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    archtec_chat.users[name] = {}
    archtec_chat.channel.join("main", name, "")
    if minetest.get_player_privs(name).staff then
        archtec_chat.channel.join("staff", name, "")
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    for cname, _ in pairs(archtec_chat.users[name]) do
        archtec_chat.channel.leave(cname, name, "")
    end
    archtec_chat.users[name] = nil
end)