archtec.faq = {}

local COLOR_BLUE = "#7AF"
local COLOR_GREEN = "#7F7"
local F = minetest.formspec_escape
local S = archtec.S
local FS = function(...) return F(S(...)) end

local FORMSPEC = [[
	size[13,7.5]
	label[0,-0.1;%s]
	tablecolumns[color;tree;text]
	table[0,0.5;4.8,6;list;%s;%i]
	box[5,0.5;7.7,6;#000]
	textarea[5.3,0.5;8,7.05;;;%s]
	button_exit[5,7;3,1;quit;%s]
]]

local defs = {}
local entries = {}
local default_description = S("For more information, click on any entry in the list. Required chatcommand arguments/parameters are indicated with angle braces <> while optional ones are have curly braces {}.")

local function faq_tree()
	for name, def in pairs(defs) do
		entries[def.header] = entries[def.header] or {}
		local entry = entries[def.header]

		entry[#entry + 1] = {name, def}
	end
	local sorted_entries = {}
	for header, content in pairs(entries) do
		table.sort(content, function(a, b) return a[2].pos < b[2].pos end) -- sort after pos
		sorted_entries[#sorted_entries + 1] = {header, content}
	end
	table.sort(sorted_entries, function(a, b) return a[1] < b[1] end)
	entries = sorted_entries
end

minetest.after(0, faq_tree)

local function faq_formspec(name, sel)
	local rows = {}

	local description = default_description

	for i, data in ipairs(entries) do
		rows[#rows + 1] = COLOR_BLUE .. ",0," .. F(data[1])
		for j, content in ipairs(data[2]) do
			rows[#rows + 1] = COLOR_GREEN .. ",1," .. content[1]
			if sel == #rows then
				description = content[2].description
			end
		end
	end

	return FORMSPEC:format(
		FS("Archtec FAQ (/faq)"),
		table.concat(rows, ","), sel or 0,
		F(description), FS("Close")
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec:faq" or fields.quit then
		return
	end

	local event = minetest.explode_table_event(fields.list)
	if event.type ~= "INV" then
		local name = player:get_player_name()
		minetest.show_formspec(name, "archtec:faq", faq_formspec(name, event.row))
	end
end)

minetest.register_chatcommand("faq", {
	description = S("View ingame FAQ"),
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/faq] executed by '" .. name .. "'")
		minetest.show_formspec(name, "archtec:faq", faq_formspec(name))
	end
})

function archtec.faq.register(name, def)
	defs[name] = def
end