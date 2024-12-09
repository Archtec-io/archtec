-- Add enchanting support for more tools
local tools = {
	moreores = {"silver", "mithril"},
	ethereal = {"crystal"},
	techage = {"meridium"},
	titanium = {"titanium"},
}

local tooltypes = {
	axe = {{"durable", "fast"}, "choppy"},
	pick = {{"durable", "fast"}, "cracky"},
	shovel = {{"durable", "fast"}, "crumbly"},
	sword = {{"sharp"}, nil},
}

for mod, materials in pairs(tools) do
	for _, material in ipairs(materials) do
		for tooltype, values in pairs(tooltypes) do
			xdecor.register_enchantable_tool(mod .. ":" .. tooltype .. "_" .. material, {
				enchants = values[1],
				dig_group = values[2],
			})
		end
	end
end
