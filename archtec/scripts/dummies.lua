minetest.register_entity(":dummies:dummy", {
	initial_properties = {
		visual = "mesh",
		mesh = "3d_armor_character.b3d",
		textures = {
			"3d_armor_trans.png",
			"3d_armor_trans.png",
		},
		collisionbox = {-0.2, 0.0, -0.2, 0.2, 1.7, 0.2},
	},

	on_punch = function(self, player)
		local name = player:get_player_name()
		if minetest.get_player_privs(name).staff then
			if player:get_player_control().sneak then
				self.object:remove()
			else
				minetest.chat_send_player(name, "Use Sneak+Punch to remove the dummy or Sneak+Rightclick to set the skin.")
			end
		end
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		local data = minetest.deserialize(staticdata) or {}
		if data.textures and type(data.textures) == "table" then
			local props = self.object:get_properties()
			props.textures = data.textures
			self.object:set_properties(props)
		end
	end,

	on_rightclick = function(self, player)
		local name = player:get_player_name()
		if minetest.get_player_privs(name).staff then
			if player:get_player_control().sneak then
				local props = self.object:get_properties()
				props.textures = {
					armor.textures[name].skin,
					armor.textures[name].armor,
					armor.textures[name].wielditem,
				}
				self.object:set_properties(props)
			else
				minetest.chat_send_player(name, "Use Sneak+Punch to remove the dummy or Sneak+Rightclick to set the skin.")
			end
		end
	end,

	get_staticdata = function(self)
		return minetest.serialize({
			textures = self.object:get_properties().textures
		})
	end
})

local function spawndummy(pos, textures)
	local dummy = minetest.add_entity(pos, "dummies:dummy", minetest.serialize({
		textures = {
			textures[1],
			textures[2],
			textures[3]
		}
	}))

	return dummy -- Return dummy object
end

-- Halloween custume textures are provided by the halloween mod
local costumes = {
	["frank"] = "halloween_suit_frank.png",
	["ghost"] = "halloween_suit_ghost.png",
	["pumpkin"] = "halloween_suit_pumpkin.png",
	["reaper"] = "halloween_suit_reaper.png",
	["skeleton"] = "halloween_suit_skeleton.png",
	["vampire"] = "halloween_suit_vampire.png",
	["wearwolf"] = "halloween_suit_wearwolf.png"
}

minetest.register_chatcommand("spawndummy", {
	params = "<name> | <costume>",
	description = "Spawn a Dummy",
	privs = {staff = true},
	func = function(name, param)
		minetest.log("action", "[/spawndummy] executed by '" .. name .. "' with param '" .. param .. "'")

		local p = archtec.get_and_trim(param)
		local player = minetest.get_player_by_name(name)
		local textures = {}

		-- Search for custome
		if p ~= "" and costumes[p] ~= nil then
			local custome = costumes[p]
			textures[1] = "blank.png"
			textures[2] = custome
			textures[3] = nil -- custom wielditem
		end

		-- Search for player skin
		local get_skin = name
		if minetest.get_player_by_name(p) then
			get_skin = p
		end
		local skin = {
			armor.textures[get_skin].skin,
			armor.textures[get_skin].armor,
			armor.textures[get_skin].wielditem
		}
		-- Overwrite values
		for k, v in ipairs(skin) do
			if textures[k] == nil then
				textures[k] = v
			end
		end

		-- Calculate position
		local look_dir = player:get_look_dir()
		local p1 = vector.add(player:get_pos(), player:get_eye_offset())
		p1.y = p1.y + player:get_properties().eye_height
		local p2 = vector.add(p1, vector.multiply(look_dir, 7))
		local raycast = minetest.raycast(p1, p2, false)
		local pointed_thing = raycast:next()

		if not pointed_thing then
			minetest.chat_send_player(name, "No position found! Point at a node when entering this command to place a dummy.")
			return
		end

		local pos = pointed_thing.intersection_point
		local dummy = spawndummy(pos, textures)

		if dummy then
			dummy:set_yaw(player:get_look_horizontal() + math.pi)
		end
	end
})