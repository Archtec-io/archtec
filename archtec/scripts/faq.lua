archtec.faq = {}
local F = minetest.formspec_escape
local S = archtec.S

local searches = {}
local defs = {}
local order_headers = {} -- set by faq_content.lua
local default_text = [[
<- Enter a keyword in the search box to do a full text search on the FAQ.
    Special tip: Run '/faq <your search here>' to search faster.

Click on any entry in the list to get information about the topics.

Required chat command arguments/parameters are indicated with angle braces "<>", optional ones have curly braces "{}".
]]

local function faq_tree(search)
	local entries = {}
	for name, def in pairs(defs) do
		if search == "" or string.find(def.text, search) then
			entries[def.header] = entries[def.header] or {}
			local len = #entries[def.header]
			entries[def.header][len + 1] = {name, def}
		end
	end
	local sorted_entries = {}
	for header, content in pairs(entries) do
		table.sort(content, function(a, b) return a[2].pos < b[2].pos end) -- sort after pos
		sorted_entries[#sorted_entries + 1] = {header, content}
	end
	table.sort(sorted_entries, function(a, b) return order_headers[a[1]] < order_headers[b[1]] end)
	return sorted_entries
end

local function faq_formspec(name, search, sel)
	local rows = {}
	local text = default_text

	local entries = faq_tree(search)
	for _, data in ipairs(entries) do
		rows[#rows + 1] = "#7AF,0," .. F(data[1])
		for _, content in ipairs(data[2]) do
			rows[#rows + 1] = "#7F7,1," .. F(content[1])
			if sel == #rows then
				text = content[2].text
			end
		end
	end

	local formspec = {
		"formspec_version[3]",
		"size[17.5,10]",
		"box[0.3,0.3;16.9,0.5;#c6e8ff]",
		"label[0.4,0.55;" .. F("Archtec FAQ (/faq)") .. "]",
		"field_close_on_enter[search_field;false]",
		"field[0.3,1.1;4.2,0.9;search_field;;" .. F(search) .. "]",
		"image_button[4.5,1.1;0.9,0.9;search.png;search_button;]",
		"tableoptions[opendepth=1]",
		"tablecolumns[color;tree;text]",
		"table[0.3,2.3;5.1,7.4;list;" .. table.concat(rows, ",") .. ";" .. sel .. "]",
		"box[5.7,1.1;11.5,8.6;#000]",
		"textarea[5.7,1.1;11.5,8.6;;;" .. F(text) .. "]",
	}

	searches[name] = search
	minetest.show_formspec(name, "archtec:faq", table.concat(formspec))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec:faq" or fields.quit then
		return
	end

	local name = player:get_player_name()
	local search = string.sub(fields.search_field or "", 1, 20)
	local event = minetest.explode_table_event(fields.list)

	if fields.search_button or (fields.search_field ~= searches[name]) then
		faq_formspec(name, search, 0)
	elseif event.type ~= "INV" then
		faq_formspec(name, search, event.row)
	end

	return true
end)

minetest.register_chatcommand("faq", {
	text = S("View ingame FAQ"),
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/faq] executed by '" .. name .. "' with param '" .. param .. "'")
		faq_formspec(name, param:sub(1, 20), 0)
	end
})

function archtec.faq.register(name, def)
	defs[name] = def
end

function archtec.faq.register_headers(def)
	order_headers = def
end

minetest.register_on_leaveplayer(function(player)
	searches[player:get_player_name()] = nil
end)