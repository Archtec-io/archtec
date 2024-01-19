archtec.faq = {}

local COLOR_BLUE = "#7AF"
local COLOR_GREEN = "#7F7"
local F = minetest.formspec_escape
local S = archtec.S
local FS = function(...) return F(S(...)) end

local FORMSPEC = [[
	formspec_version[3]
	size[17,9.6]
	label[0.4,0.4;%s]
	tableoptions[opendepth=1]
	tablecolumns[color;tree;text]
	table[0.4,0.8;5.8,7;list;%s;%i]
	box[6.6,0.8;10,7;#000]
	textarea[6.6,0.8;10,7;;;%s]
	button_exit[7,8.2;3,1;quit;%s]
]]

local defs = {}
local order_headers = {}
local entries = {}
local default_text = [[
For more information, click on any entry in the list.

Required chat command arguments/parameters are indicated with angle braces "<>",
optional ones have curly braces "{}".
]]

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
	table.sort(sorted_entries, function(a, b) return order_headers[a[1]] < order_headers[b[1]] end)
	entries = sorted_entries
end

minetest.after(0, faq_tree)

local function faq_formspec(sel)
	local rows = {}

	local text = default_text

	for _, data in ipairs(entries) do
		rows[#rows + 1] = COLOR_BLUE .. ",0," .. F(data[1])
		for _, content in ipairs(data[2]) do
			rows[#rows + 1] = COLOR_GREEN .. ",1," .. F(content[1])
			if sel == #rows then
				text = content[2].text
			end
		end
	end

	return FORMSPEC:format(
		FS("Archtec FAQ (/faq)"),
		table.concat(rows, ","), sel or 0,
		F(text), FS("Close")
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec:faq" or fields.quit then
		return
	end

	local event = minetest.explode_table_event(fields.list)
	if event.type ~= "INV" then
		local name = player:get_player_name()
		minetest.show_formspec(name, "archtec:faq", faq_formspec(event.row))
	end
end)

minetest.register_chatcommand("faq", {
	text = S("View ingame FAQ"),
	privs = {interact = true},
	func = function(name)
		minetest.log("action", "[/faq] executed by '" .. name .. "'")
		minetest.show_formspec(name, "archtec:faq", faq_formspec())
	end
})

function archtec.faq.register(name, def)
	defs[name] = def
end

function archtec.faq.register_headers(def)
	order_headers = def
end