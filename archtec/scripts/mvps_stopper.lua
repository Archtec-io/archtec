if not core.get_modpath("mesecons") then return end

if core.get_modpath("3d_armor_stand") then
	mesecon.register_mvps_stopper("3d_armor_stand:armor_stand")
	mesecon.register_mvps_stopper("3d_armor_stand:locked_armor_stand")
end

if core.get_modpath("christmas_decor") then
	mesecon.register_mvps_stopper("christmas_decor:stocking")
end

local function unregister_stopper(nodename)
	mesecon.mvps_stoppers[nodename] = nil
end

unregister_stopper("default:chest")
unregister_stopper("default:chest_open")
unregister_stopper("default:chest_locked")
unregister_stopper("default:chest_locked_open")
unregister_stopper("default:furnace")
unregister_stopper("default:furnace_active")
