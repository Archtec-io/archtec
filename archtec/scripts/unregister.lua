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

if minetest.get_modpath("abriglass") then
    minetest.unregister_item("abriglass:ghost_crystal")
end

if minetest.get_modpath("currency") then
    minetest.unregister_item("currency:minegeld_bundle")
    minetest.unregister_item("currency:shop")
end