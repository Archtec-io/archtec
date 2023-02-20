function archtec.get_target(name, param)
    local target = param:trim()
    if target == "" or target == nil or type(target) ~= "string" then
        target = name
    end
    return target
end

function archtec.is_online(name)
    local player = minetest.get_player_by_name(name)
	if not player then
		return false
	end
    return true
end