if minetest.get_modpath("atm") then
    minetest.unregister_item("atm1")
    minetest.unregister_item("atm2")
    minetest.unregister_item("atm:wtt")
end

if minetest.get_modpath("tpr") then
    minetest.unregister_chatcommand("tpc")
    minetest.unregister_chatcommand("tpj")
end