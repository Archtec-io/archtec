if minetest.get_modpath("atm") then
    minetest.unregister_item("atm:atm")
    minetest.unregister_item("atm:atm2")
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

if minetest.get_modpath("xdecor") then
    minetest.unregister_item("xdecor:cobweb")
end

if minetest.get_modpath("homedecor_cobweb") then
    minetest.unregister_item("homedecor:cobweb_corner")
end