--override abms
for _, ab in pairs(minetest.registered_abms) do

	local label = ab.label or ""
	local node1 = ab.nodenames and ab.nodenames[1] or ""

    if label == "spawn bee hives" and node1 == "group:leaves" then
		ab.nodenames = {"default:leaves"}
    end

	if label == "mobs_animal:bunny spawning" then
		ab.chance = 6000 --8000
	elseif label == "mobs_animal:chicken spawning" then
		ab.chance = 6000 --8000
	elseif label == "mobs_animal:cow spawning" then
		ab.chance = 6000 --8000
	elseif label == "mobs_animal:kitten spawning" then
		ab.chance = 8000 --10000
	elseif label == "mobs_animal:panda spawning" then
		ab.chance = 6000 --8000
	elseif label == "mobs_animal:sheep_white spawning" then
		ab.chance = 6000 --8000
	elseif label == "mobs_animal:pumba spawning" then
		ab.chance = 6000 --8000
	end

	if label == "mobs_monster:dirt_monster spawning" then
		ab.chance = 3500 --6000
	elseif label == "mobs_monster:dungeon_master spawning" then
		ab.chance = 7000 --9000
	elseif label == "mobs_monster:mese_monster spawning" then
		ab.chance = 3500 --5000
	elseif label == "mobs_monster:oerkki spawning" then
		ab.chance = 3500 --7000
	elseif label == "mobs_monster:sand_monster spawning" then
		ab.chance = 3500 --5000
	elseif label == "mobs_monster:spider spawning" then
		ab.chance = 5000 --7000
	elseif label == "mobs_monster:stone_monster spawning" then
		ab.chance = 3500 --7000
	elseif label == "mobs_monster:tree_monster spawning" then
		ab.chance = 3500 --7000
	end
end
