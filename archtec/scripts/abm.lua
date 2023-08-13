local group_grass = {
	"default:dry_grass_1",
	"default:dry_grass_2",
	"default:dry_grass_3",
	"default:dry_grass_4",
	"default:dry_grass_5",
	"default:fern_1",
	"default:fern_2",
	"default:fern_3",
	"default:grass_1",
	"default:grass_2",
	"default:grass_3",
	"default:grass_4",
	"default:grass_5",
	"default:junglegrass",
	"default:marram_grass_1",
	"default:marram_grass_2",
	"default:marram_grass_3",
}

local group_dry_grass = {
	"default:dry_grass_1",
	"default:dry_grass_2",
	"default:dry_grass_3",
	"default:dry_grass_4",
	"default:dry_grass_5",
}

-- override abms
for _, ab in ipairs(minetest.registered_abms) do

	local label = ab.label or ""
	local node1 = ab.nodenames and ab.nodenames[1] or ""

	if label == "spawn bee hives" and node1 == "group:leaves" then
		ab.nodenames = {"default:leaves"}
	end

	if label == "mobs_animal:bunny spawning" then
		ab.chance = ab.chance * 0.75
		ab.neighbours = group_grass
	elseif label == "mobs_animal:chicken spawning" then
		ab.chance = ab.chance * 0.75
		ab.neighbours = group_grass
	elseif label == "mobs_animal:cow spawning" then
		ab.neighbours = group_grass
	elseif label == "mobs_animal:kitten spawning" then
		ab.chance = ab.chance * 0.75
		ab.neighbours = group_grass
	elseif label == "mobs_animal:panda spawning" then
		ab.chance = ab.chance * 0.75
		ab.neighbours = group_grass
	elseif label == "mobs_animal:sheep_white spawning" then
		ab.neighbours = group_grass
	elseif label == "mobs_animal:pumba spawning" then
		ab.chance = ab.chance * 0.75
		ab.neighbours = group_dry_grass
	end

	if label == "mobs_monster:dirt_monster spawning" then
		ab.chance = ab.chance * 0.5
	elseif label == "mobs_monster:dungeon_master spawning" then
		ab.chance = ab.chance * 0.5
	elseif label == "mobs_monster:mese_monster spawning" then
		ab.chance = ab.chance * 0.5
	elseif label == "mobs_monster:oerkki spawning" then
		ab.chance = ab.chance * 0.5
	elseif label == "mobs_monster:sand_monster spawning" then
		ab.chance = ab.chance * 0.5
	elseif label == "mobs_monster:spider spawning" then
		ab.chance = ab.chance * 0.5
	elseif label == "mobs_monster:stone_monster spawning" then
		ab.chance = ab.chance * 0.5
	elseif label == "mobs_monster:tree_monster spawning" then
		ab.chance = ab.chance * 0.5
	end
end

-- Slow ABM/NodeTimer/LBM logger
local get_us_time, P2S = minetest.get_us_time, minetest.pos_to_string

local abm_max_time = 5000 -- 5 ms
local nt_max_time = 10000 -- 10 ms
local lbm_max_time = 10000 -- 10 ms

function archtec.abm_max_time(t)
	abm_max_time = t
end

function archtec.nt_max_time(t)
	nt_max_time = t
end

function archtec.lbm_max_time(t)
	lbm_max_time = t
end

local function inc_abm(label, diff, pos, nn)
	if diff > abm_max_time then
		minetest.log("action", "ABM '" .. label .. "', took '" .. diff .. "' us, pos '" .. P2S(pos) .. "', node '" .. nn .. "'")
	end
end

local function inc_nt(diff, pos)
	if diff > nt_max_time then
		local nn = minetest.get_node(pos).name
		minetest.log("action", "NodeTimer took '" .. diff .. "' us, pos '" .. P2S(pos) .. "', node '" .. nn .. "'")
	end
end

local function inc_lbm(label, diff, pos, nn)
	if diff > lbm_max_time then
		minetest.log("action", "LBM '" .. label .. "', took '" .. diff .. "' us, pos '" .. P2S(pos) .. "', node '" .. nn .. "'")
	end
end

minetest.register_on_mods_loaded(function()
	for _, abm in ipairs(minetest.registered_abms) do
		local old_action = abm.action
		abm.action = function(pos, node, active_object_count, active_object_count_wider)
			local t0 = get_us_time()
			old_action(pos, node, active_object_count, active_object_count_wider)
			local diff = get_us_time() - t0
			inc_abm(abm.label or "??", diff, pos, node.name)
		end
	end

	for _, def in pairs(minetest.registered_nodes) do
		if def.on_timer then
			local old_action = def.on_timer
			def.on_timer = function(pos, elapsed)
				local t0 = get_us_time()
				local res = old_action(pos, elapsed)
				local diff = get_us_time() - t0
				inc_nt(diff, pos)
				return res
			end
		end
	end

	for _, lbm in ipairs(minetest.registered_lbms) do
		local old_action = lbm.action
		lbm.action = function(pos, node, dtime_s)
			local t0 = get_us_time()
			old_action(pos, node, dtime_s)
			local diff = get_us_time() - t0
			inc_lbm(lbm.label or "??", diff, pos, node.name)
		end
	end
end)
