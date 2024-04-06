local function copy_drawer(name)
	local def = table.copy(minetest.registered_nodes["drawers:" .. name])
	def.name = nil
	def.description = def.description .. " (fake)"
	def.groups.not_in_creative_inventory = 1
	def.groups.drawer = nil
	-- Disable callbacks
	def.on_construct = nil
	def.on_dig = nil
	def.on_destruct = nil
	def.on_place = nil
	def.on_rotate = nil
	def.allow_metadata_inventory_put = nil
	def.allow_metadata_inventory_take = nil
	def.on_metadata_inventory_put = nil
	def.on_metadata_inventory_take = nil

	minetest.register_node("archtec:" .. name, def)
end

copy_drawer("acacia_wood1")
copy_drawer("acacia_wood2")
copy_drawer("acacia_wood4")

copy_drawer("aspen_wood1")
copy_drawer("aspen_wood2")
copy_drawer("aspen_wood4")

copy_drawer("junglewood1")
copy_drawer("junglewood2")
copy_drawer("junglewood4")

copy_drawer("pine_wood1")
copy_drawer("pine_wood2")
copy_drawer("pine_wood4")

copy_drawer("wood1")
copy_drawer("wood2")
copy_drawer("wood4")