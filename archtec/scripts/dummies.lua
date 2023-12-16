local dummy_objs = {}
local light_levels = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14"

-- Costume definitions (textures are provided by the halloween/christmas mod)
local costumes = {
	-- halloween
	frank = {texture = "halloween_suit_frank.png", name = "Frank"},
	ghost = {texture = "halloween_suit_ghost.png", name = "Ghost"},
	pumpkin = {texture = "halloween_suit_pumpkin.png", name = "Pumpkin"},
	reaper = {texture = "halloween_suit_reaper.png", name = "Reaper"},
	skeleton = {texture = "halloween_suit_skeleton.png", name = "Skeleton"},
	vampire = {texture = "halloween_suit_vampire.png", name = "Vampire"},
	wearwolf = {texture = "halloween_suit_wearwolf.png", name = "Wearwolf"},
	-- christmas
	mrs_claus = {texture = "christmas_decor_mrs_claus.png", name = "Mrs. Claus"},
	santa_claus = {texture = "christmas_decor_santa.png", name = "Santa Claus"}
}

-- Formspec menu design
local form = {
	tabs = {
		{name = "general", title = "General"},
		{name = "style_head", title = "Style related", style = "head"},
		{name = "skin", title = "Skin"},
		{name = "nametag", title = "Nametag"}
	}
}

-- Supported nametag colors
local colors = {
	white = {a = 255, r = 255, g = 255, b = 255},
	red = {a = 255, r = 255, g = 0, b = 0},
	green = {a = 255, r = 0, g = 255, b = 0},
	blue = {a = 255, r = 0, g = 0, b = 255},
	yellow = {a = 255, r = 255, g = 255, b = 0},
}
local color_str = "white,red,green,blue,yellow"

local costume_list = {}
local function generate_costume_list()
	for name, _ in pairs(costumes) do
		table.insert(costume_list, name)
	end
end
generate_costume_list()

local function find_costume(textures)
	for _, tex in ipairs(textures) do
		for i, costume in pairs(costume_list) do
			if tex == costumes[costume].texture then
				return i
			end
		end
	end
end

local function valid_ref(ref)
	if ref and ref.get_properties then
		local props = ref:get_properties()
		if props then
			return true
		end
	end
	return false
end

local function find_color(spec)
	local colorname = "white"
	for cname, color in pairs(colors) do
		if spec.r == color.r and spec.g == color.g and spec.b == spec.b then
			colorname = cname
		end
	end
	local color_split = color_str:split(",")
	for i, c in ipairs(color_split) do
		if c == colorname then
			return i
		end
	end
end

local function echo_desc(name, ownername)
	if name == ownername or minetest.get_player_privs(name).builder then
		minetest.chat_send_player(name, "Use Sneak+Punch to remove the dummy or Sneak+Rightclick to edit the dummy. Owner of this dummy is " .. (ownername or "unknown") .. ".")
	else
		minetest.chat_send_player(name, "Owner of this dummy is " .. (ownername or "unknown") .. ".")
	end
end

local function show_fs(name, active_tab)
	active_tab = active_tab or "general"

	local dummy = dummy_objs[name]
	if not valid_ref(dummy) then
		return
	end
	local props = dummy:get_properties()

	local formspec = "formspec_version[4]size[13.2,11]"

	-- Tabs
	for i, tab in pairs(form.tabs) do
		if tab.name == active_tab then
			formspec = formspec ..
				"style[" .. tab.name .. ";bgcolor=green]"
		end

		local y = 0.3 + (i - 1) * 0.8
		if not tab.style then
			formspec = formspec ..
				"button[0.3," .. y .. ";3,0.8;" .. tab.name .. ";" .. tab.title .. "]"

		elseif tab.style == "head" then
			y = y + 0.25
			formspec = formspec ..
				"hypertext[0.3," .. y .. ";3,0.8;head_" .. tab.name .. ";<center><b>" .. tab.title .. "</b></center>]"
		end
	end

	-- Dummy preview
	if props.mesh then
		local textures = dummy:get_properties().textures
		formspec = formspec ..
			"model[10,0.3;3,7.5;dummy_mesh;" .. props.mesh .. ";" .. table.concat(textures, ",") .. ";0,150;false;true;0,0]"
	end

	-- Show tab content
	local x = 4
	local y = 0.4
	if active_tab == "general" then
		-- Delete dummy
		formspec = formspec ..
			"label[" .. x .. "," .. y .. ";Delete this dummy]"
		y = y + 0.3

		formspec = formspec ..
			"style[act_del_dummy;bgcolor=red]" ..
			"button[" .. x .. "," .. y .. ";3,0.8;act_del_dummy;Delete]"

		y = y + 1.5
		-- Set luminosity
		formspec = formspec ..
			"label[" .. x .. "," .. y .. ";Change luminosity]"
		y = y + 0.3

		formspec = formspec ..
			"dropdown[" .. x .. "," .. y .. ";4,0.8;luminosity;" .. light_levels .. ";" .. (props.glow or 0) .. ";false]"

		formspec = formspec ..
			"button[" .. x + 4 .. "," .. y .. ";2,0.8;act_set_luminosity;Set]"

		y = y + 1.5
		-- Enable animation
		local enable_animation = dummy:get_luaentity()._enable_animation
		if enable_animation == nil then enable_animation = false end
		formspec = formspec ..
			"checkbox[" .. x .. "," .. y .. ";model_enable_aninmation;Enable standing animation;" .. tostring(enable_animation) .. "]"

	elseif active_tab == "nametag" then
		-- Set nametag string
		formspec = formspec ..
			"label[" .. x .. "," .. y .. ";Change nametag]"
		y = y + 0.3

		formspec = formspec ..
			"field[" .. x .. "," .. y .. ";4,0.8;nametag_str;;" .. props.nametag .. "]"

		formspec = formspec ..
			"button[" .. x + 4 .. "," .. y .. ";2,0.8;act_set_nametag_str;Set]"

		y = y + 1.5
		-- Nametag color
		formspec = formspec ..
			"label[" .. x .. "," .. y .. ";Change nametag color]"
		y = y + 0.3

		formspec = formspec ..
			"dropdown[" .. x .. "," .. y .. ";4,0.8;nametag_color;" .. color_str .. ";" .. find_color(props.nametag_color) .. ";false]"

		formspec = formspec ..
			"button[" .. x + 4 .. "," .. y .. ";2,0.8;act_set_nametag_color;Set]"

	elseif active_tab == "skin" then
		-- Set to costume
		local costumes_str = ""
		for i, costume in pairs(costumes) do
			costumes_str = costumes_str .. costume.name .. ","
		end
		costumes_str = costumes_str:sub(1, #costumes_str - 1)
		local idx = find_costume(props.textures) or 0

		formspec = formspec ..
			"label[" .. x .. "," .. y .. ";Set skin to costume]"
		y = y + 0.3

		formspec = formspec ..
			"dropdown[" .. x .. "," .. y .. ";4,0.8;skin_costume;" .. costumes_str .. ";" .. idx .. ";true]"

		formspec = formspec ..
			"button[" .. x + 4 .. "," .. y .. ";2,0.8;act_set_skin_costume;Set]"

		y = y + 1.5
		-- Set to player skin
		local pnames = ""
		for _, player in ipairs(minetest.get_connected_players()) do
			pnames = pnames .. player:get_player_name() .. ","
		end
		pnames = pnames:sub(1, #pnames - 1)

		formspec = formspec ..
			"label[" .. x .. "," .. y .. ";Set skin to player skin]"
		y = y + 0.3

		formspec = formspec ..
			"dropdown[" .. x .. "," .. y .. ";4,0.8;skin_player;" .. pnames .. ";0;false]"

		formspec = formspec ..
			"button[" .. x + 4 .. "," .. y .. ";2,0.8;act_set_skin_player;Set]"

		y = y + 1.5
		-- Show armor
		local show_armor = dummy:get_luaentity()._skin_show_armor
		if show_armor == nil then show_armor = true end
		formspec = formspec ..
			"checkbox[" .. x .. "," .. y .. ";skin_show_armor;Show armor;" .. tostring(show_armor) .. "]"

		y = y + 0.5
		-- Show wielditem
		local show_wielditem = dummy:get_luaentity()._skin_show_wielditem
		if show_wielditem == nil then show_wielditem = true end
		formspec = formspec ..
			"checkbox[" .. x .. "," .. y .. ";skin_show_wielditem;Show wielditem;" .. tostring(show_wielditem) .. "]"

	end

	minetest.show_formspec(name, "archtec:dummy_" .. active_tab, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formname:find("^archtec:dummy") then return false end

	local _, _, active_tab = formname:find("^archtec:dummy_(%a+)")
	if not active_tab then return true end

	local name = player:get_player_name()

	local dummy = dummy_objs[name]
	if not valid_ref(dummy) then
		return true
	end
	local props = dummy:get_properties()

	-- Owner check
	if not minetest.get_player_privs(name).builder and dummy:get_luaentity()._ownername ~= name then
		return true
	end

	-- Set next authorized player to owner
	if not dummy:get_luaentity()._ownername then
		dummy:get_luaentity()._ownername = name
	end

	-- Delete Dummy
	if fields.act_del_dummy then
		dummy:remove()
		minetest.close_formspec(name, formname)
		return true

	-- Enable animation
	elseif fields.model_enable_aninmation then
		if fields.model_enable_aninmation == "true" then
			dummy:set_animation({x = 0, y = 79}, 30, 0, true)
			dummy:get_luaentity()._enable_animation = true
		else
			dummy:set_animation()
			dummy:get_luaentity()._enable_animation = false
		end

	-- Set nametag string
	elseif fields.nametag_str and fields.act_set_nametag_str then
		props.nametag = fields.nametag_str

	-- Set nametag color
	elseif fields.nametag_color and fields.act_set_nametag_color then
		if colors[fields.nametag_color] then
			props.nametag_color = colors[fields.nametag_color]
		end

	-- Set skin costume
	elseif fields.skin_costume and fields.act_set_skin_costume then
		local tex_name = costume_list[tonumber(fields.skin_costume)]
		if tex_name then
			props.textures[1] = costumes[tex_name].texture
			props.textures[2] = armor.textures[name].armor
			props.textures[3] = armor.textures[name].wielditem
			dummy:get_luaentity()._skin_show_armor = true
			dummy:get_luaentity()._skin_show_wielditem = true
		end

	-- Set skin to player skin
	elseif fields.skin_player and fields.act_set_skin_player then
		local target_name = fields.skin_player
		local target_player = minetest.get_player_by_name(target_name)
		if target_player then
			props.textures[1] = armor.textures[target_name].skin
			props.textures[2] = armor.textures[target_name].armor
			props.textures[3] = armor.textures[target_name].wielditem

			dummy:get_luaentity()._skin_show_armor = true
			dummy:get_luaentity()._skin_show_wielditem = true
		end

	-- Set luminosity
	elseif fields.luminosity and fields.act_set_luminosity then
		local luminosity = tonumber(fields.luminosity)
		if luminosity >= 0 and luminosity <= 14 then
			props.glow = luminosity + 1 -- hack
		end
	end

	-- Show armor
	if fields.skin_show_armor == "false" then
		props.textures[2] = "blank.png"
		dummy:get_luaentity()._skin_show_armor = false
	elseif fields.skin_show_armor == "true" then
		props.textures[2] = armor.textures[name].armor
		dummy:get_luaentity()._skin_show_armor = true
	end

	-- Show wielditem
	if fields.skin_show_wielditem == "false" then
		props.textures[3] = "blank.png"
		dummy:get_luaentity()._skin_show_wielditem = false
	elseif fields.skin_show_wielditem == "true" then
		props.textures[3] = armor.textures[name].wielditem
		dummy:get_luaentity()._skin_show_wielditem = true
	end

	-- Write props back
	dummy:set_properties(props)

	-- Switch tab
	for _, tab in pairs(form.tabs) do
		if fields[tab.name] then
			show_fs(name, tab.name)
			return true
		end
	end

	-- Show new formspec
	if not fields.quit then
		show_fs(name, active_tab)
	end

	return true
end)


minetest.register_entity(":dummies:dummy", {
	initial_properties = {
		visual = "mesh",
		mesh = "3d_armor_character.b3d",
		textures = {},
		collisionbox = {-0.35, 0.0, -0.35, 0.35, 1.8, 0.35},
		_skin_show_armor = true,
		_skin_show_wielditem = true
	},

	on_punch = function(self, player)
		local name = player:get_player_name()
		if self._ownername == name or minetest.get_player_privs(name).builder then
			if player:get_player_control().sneak then
				self.object:remove()
			else
				echo_desc(name, self._ownername)
			end
		else
			echo_desc(name, self._ownername)
		end
	end,

	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal = 1})
		local data = minetest.deserialize(staticdata) or {}
		local props = self.object:get_properties()

		if data.textures and type(data.textures) == "table" then
			props.textures = data.textures
		end

		if data.glow then props.glow = data.glow end
		if data.nametag then props.nametag = data.nametag end
		if data.nametag_color then props.nametag_color = data.nametag_color end

		if data.show_armor ~= nil then self._skin_show_armor = data.show_armor end
		if data.show_wielditem ~= nil then self._skin_show_wielditem = data.show_wielditem end

		if data.enable_animation ~= nil then
			self._enable_animation = data.enable_animation
			if data.enable_animation == true then
				self.object:set_animation({x = 0, y = 79}, 30, 0, true)
			end
		end

		if data.ownername ~= nil then self._ownername = data.ownername end

		self.object:set_properties(props)
	end,

	on_rightclick = function(self, player)
		local name = player:get_player_name()
		if self._ownername == name or minetest.get_player_privs(name).builder then
			if player:get_player_control().sneak then
				dummy_objs[name] = self.object
				show_fs(name)
			else
				echo_desc(name, self._ownername)
			end
		else
			echo_desc(name, self._ownername)
		end
	end,

	get_staticdata = function(self)
		local props = self.object:get_properties()
		return minetest.serialize({
			textures = props.textures,
			glow = props.glow,
			nametag = props.nametag,
			nametag_color = props.nametag_color,
			show_armor = self._skin_show_armor,
			show_wielditem = self._skin_show_wielditem,
			enable_animation = self._enable_animation,
			ownername = self._ownername
		})
	end,
})

local function spawndummy(pos, textures, name)
	local dummy = minetest.add_entity(pos, "dummies:dummy", minetest.serialize({
		textures = {
			textures[1],
			textures[2],
			textures[3]
		},
		_ownername = name
	}))

	return dummy -- Return dummy object
end

minetest.register_chatcommand("spawndummy", {
	params = "",
	description = "Spawn a Dummy",
	func = function(name, param)
		minetest.log("action", "[/spawndummy] executed by '" .. name .. "' with param '" .. param .. "'")
		local player = minetest.get_player_by_name(name)

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

		local textures = {
			armor.textures[name].skin,
			armor.textures[name].armor,
			armor.textures[name].wielditem
		}

		local pos = pointed_thing.intersection_point
		local dummy = spawndummy(pos, textures, name)

		if dummy then
			dummy:set_yaw(player:get_look_horizontal() + math.pi)
			dummy_objs[name] = dummy
			show_fs(name)
		end
	end
})