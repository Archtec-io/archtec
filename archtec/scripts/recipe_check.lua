-- Find duplicate crafting recipes

local function get_depend_checker(modname)
	local self = {
		modname = modname,
		depends = {} -- depends.txt parsed
	}

	-- Check if dependency exists to mod modname
	function self:check_depend(modname, deptype)
		if self.depends[modname] then
			if not deptype then  -- "required" or "optional" only
				return true
			else
				return (self.depends[modname] == deptype)
			end
		else
			return false
		end
	end

	-- Check if dependency exists to item origin mod
	function self:check_depend_by_itemname(itemname, deptype)
		local modname = archtec.get_modname_by_itemname(itemname)
		if modname then
			return self:check_depend(modname, deptype)
		else
			return false
		end
	end

	-- get module path
	local modpath = minetest.get_modpath(modname)
	if not modpath then
		return nil -- module not found
	end

	-- read the depends file
	local dependsfile = io.open(modpath .. "/depends.txt")
	if not dependsfile then
		return nil
	end

	-- parse the depends file
	for line in dependsfile:lines() do
		if line:sub(-1) == "?" then
			line = line:sub(1, -2)
			self.depends[line] = "optional"
		else
			self.depends[line] = "required"
		end
	end
	dependsfile:close()
	return self
end

local function dependency_exists(item1, item2)
    local modname1, modname2, depmod, delimpos

    -- the items are from crafting output so maybe the counter needs to be cutted
    delimpos = string.find(item1, " ")
    if delimpos then
        item1 = string.sub(item1, 1, delimpos - 1)
    end

    delimpos = string.find(item2, " ")
    if delimpos then
        item2 = string.sub(item2, 1, delimpos - 1)
    end

    -- check dependency item1 depends on item2
    modname1 = archtec.get_modname_by_itemname(item1)
    modname2 = archtec.get_modname_by_itemname(item2)

    if not modname1 or modname1 == "group" or
        not modname2 or modname2 == "group" then
        return false
    end

    if modname1 == modname2 then
        return false -- there should not be a redefinition in same module
    end
    depmod = get_depend_checker(modname1)
    if depmod and depmod:check_depend(modname2) then
        return true
    end

    depmod = get_depend_checker(modname2)
    if depmod and depmod:check_depend(modname1) then
        return true
    end
end

local function is_same_item(item1, item2)

	local chkgroup = nil
	local chkitem = nil

    -- simple check by name (group match is ok/true too)
	if item1 == item2 then -- simple check
		return true
	end

	if not item1 or not item2 then -- if one of the items not there => difference
		return false
	end

    -- group check
    if item1:sub(1, 6) == "group:" then
        chkgroup = item1:sub(7)
        chkitem  = item2
    end

    if item2:sub(1, 6) == "group:" then
        if chkgroup then -- defined from item1, but not the same in simple check
            return false
        else
            chkgroup = item2:sub(7)
            chkitem  = item1
        end
    end

    if chkgroup and chkitem then
        local chkitemdef = minetest.registered_nodes[chkitem]
        if not chkitemdef then -- should not be happen. But unknown item cannot be in a group
            return false
        elseif chkitemdef.groups[chkgroup] then -- is in the group
            return true
        end
    end

	-- checks for the same item not passed
	return false
end



local function is_same_recipe(rec1, rec2)
    -- Maybe TODO? : recalculation to universal format (width=0). same recipes can be defined in different ways (no samples)
	if not (rec1.items or rec2.items) then  -- nil means no recipe that is never the same oO
		return false
	end

	if rec1.type  ~= rec2.type or
	   rec1.width ~= rec2.width then
		return false
	end

	for i =1, 9 do  -- check all fields. max recipe is  3x3e
		if not is_same_item(rec1.items[i], rec2.items[i]) then
			return false
		end
	end
	return true  -- checks passed, no differences found
end


local known_recipes = {}

local function run(pname)
    for name, def in archtec.pairs_by_key(minetest.registered_items) do
        if (not def.groups.not_in_creative_inventory or
        def.groups.not_in_creative_inventory == 0) and
        def.description and def.description ~= "" then  -- check valide entrys only

            local recipes_for_node = minetest.get_all_craft_recipes(name)
            if recipes_for_node ~= nil then
                for kn, vn in ipairs(recipes_for_node) do
                    for ku, vu in ipairs(known_recipes) do
                        if vu.output ~= vn.output and
                        is_same_recipe(vu, vn) == true then
                            if not dependency_exists(vu.output, vn.output) then
                                minetest.log("warning", "[recipe-check] " .. vu.output .. " " .. vn.output)
                                if name then
                                    minetest.chat_send_player(pname, minetest.colorize("#FF0000", "[recipe-check] " .. vu.output .. " " .. vn.output))
                                end
                            end
                        end
                    end
                    table.insert(known_recipes, vn )
                end
            end
        end
    end
    known_recipes = {}
end

minetest.register_chatcommand("recipe_check", {
	description = "Get recipe bugs",
	privs = {staff = true},
	func = function(name, param)
		run(name)
    end
})