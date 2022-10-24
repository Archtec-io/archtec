--override bees abm
for _, ab in pairs(minetest.registered_abms) do

	local label = ab.label or ""
	local node1 = ab.nodenames and ab.nodenames[1] or ""

	if label == "spawn bee hives" and node1 == "group:leaves" then
		ab.nodenames = {"default:leaves"}
    end
end
