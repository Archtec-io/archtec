core.unregister_chatcommand("ban")
core.unregister_chatcommand("unban")
core.unregister_chatcommand("rollback")
core.unregister_chatcommand("rollback_check")
core.unregister_chatcommand("set")

if core.get_modpath("atm") then
	core.unregister_item("atm:atm")
	core.unregister_item("atm:atm2")
end

if core.get_modpath("currency") then
	core.unregister_item("currency:minegeld_bundle")
	core.unregister_item("currency:shop")
	core.unregister_item("currency:shop_empty")
end

if core.get_modpath("xdecor") then
	core.unregister_item("xdecor:cobweb")
end

if core.get_modpath("mesecons_debug") then
	core.unregister_item("mesecons_debug:mesecons_lagger")
end

if core.get_modpath("abriglass") then
	core.unregister_item("abriglass:porthole_junglewood")
	core.unregister_item("abriglass:porthole_wood")
end

if core.get_modpath("shields") then
	core.unregister_item("shields:shield_nether")
	core.unregister_item("invisible_shields:shield_nether")
end

if core.get_modpath("ambience") then
	core.unregister_chatcommand("mvol")
end

if core.get_modpath("prefab") then
	core.unregister_item("prefab:boat")
end
