if minetest.get_modpath("atm") then
    minetest.unregister_item("atm:atm")
    minetest.unregister_item("atm:atm2")
end

if minetest.get_modpath("tpr") then
    minetest.unregister_chatcommand("tpc")
    minetest.unregister_chatcommand("tpj")
end

minetest.unregister_chatcommand("ban")
minetest.unregister_chatcommand("unban")