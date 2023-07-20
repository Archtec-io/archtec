if minetest.get_modpath("atm") then
	minetest.unregister_item("atm:atm")
	minetest.unregister_item("atm:atm2")
end

minetest.unregister_chatcommand("ban")
minetest.unregister_chatcommand("unban")
minetest.unregister_chatcommand("rollback")
minetest.unregister_chatcommand("rollback_check")
minetest.unregister_chatcommand("set")

if minetest.get_modpath("currency") then
	minetest.unregister_item("currency:minegeld_bundle")
	minetest.unregister_item("currency:shop")
	minetest.unregister_item("currency:shop_empty")
end

if minetest.get_modpath("xdecor") then
	minetest.unregister_item("xdecor:cobweb")
end

if minetest.get_modpath("mesecons_debug") then
	minetest.unregister_item("mesecons_debug:mesecons_lagger")
end

if minetest.get_modpath("abriglass") then
	minetest.unregister_item("abriglass:porthole_junglewood")
	minetest.unregister_item("abriglass:porthole_wood")
end

if minetest.get_modpath("shields") then
	minetest.unregister_item("shields:shield_nether")
	minetest.unregister_item("invisible_shields:shield_nether")
end
