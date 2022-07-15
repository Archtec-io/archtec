if minetest.get_modpath("mesecons_mvps") ~= nil and minetest.get_modpath("3d_armor_stand") ~= nil then
	mesecon.register_mvps_stopper("3d_armor_stand:armor_stand")
	mesecon.register_mvps_stopper("3d_armor_stand:locked_armor_stand")
end