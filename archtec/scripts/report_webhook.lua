local http = assert(...)
local S = archtec.S
local webhook_url = minetest.settings:get("archtec.webhook_url")
local report_gpg_key = minetest.settings:get("archtec.report_gpg_key")

if not report_gpg_key or not webhook_url then
	error("[archtec] No report keys found!")
end

local function test_json(name, report)
	local json = minetest.write_json({
		title = "Report Test by " .. name .. ": " .. report
	})
	if json == nil then
		return false
	end
	return true
end

-- func stolen at https://github.com/fluxionary/minetest-bug_command/blob/653ac5191f7cc4350b8a96bddebbc7b4f8280bef/init.lua#L25
local function create_title(param)
	local parts = param:split("%s+", false, -1, true)
	local title_length = 0
	local title_parts = {}
	for _, part in ipairs(parts) do
		table.insert(title_parts, part)
		title_length = title_length + part:len() + 1
		if title_length > 40 then
			table.insert(title_parts, "...")
			break
		end
	end
	return table.concat(title_parts, " ")
end

local function clean_meta(m)
	local meta = table.copy(m) -- not sure if we need this...
	if meta.ui_waypoints then -- waypoints may contain private data
		meta.ui_waypoints = nil
	end
	return meta
end

local function send_report(name, report)
	local player = minetest.get_player_by_name(name)
	local pos
	if player then
		pos = dump(player:get_pos())
	else
		pos = "unknown"
	end
	local meta
	if player then
		meta = dump(clean_meta(player:get_meta():to_table()))
	else
		meta = "unknown"
	end
	local json = minetest.write_json({
		title = "Report by " .. name .. ": " .. create_title(report),
		body = "**Report by " .. name .. ":**\n > " .. report .. "\n\n**Position:**\n```\n" .. pos .. "\n```\n" .. "\n\n**Meta:**\n```\n" .. meta .. "\n```\n" .. "\n\n**Server status:**\n```\n" .. minetest.get_server_status() .. "\n```\n",
	})

	if json == nil then
		return false
	end

	http.fetch({
		url = "https://api.github.com/repos/Archtec-io/bugtracker/issues",
		method = "POST",
		extra_headers = {
			"Accept: application/vnd.github+json",
			"Authorization: Bearer " .. report_gpg_key,
			"X-GitHub-Api-Version: 2022-11-28"
		},
		data = json,
	}, function(res)
		local parse = minetest.parse_json(res.data)
		if parse.html_url then
			notifyTeam("[archtec] " .. name .. " reported an Issue: " .. report .. " URL: " .. parse.html_url)
		else
			notifyTeam("[archtec] " .. name .. " reported an Issue: " .. report .. " URL: unknown; JSON parsing error!")
		end

		if player then
			pos = tostring(player:get_pos())
		else
			pos = "unknown"
		end
		if not parse.html_url then
			parse.html_url = "Unknown URL"
		end
		local json = minetest.write_json({
			embeds = {{
				title = "Report by " .. name .. ":",
				description = report .. "\n\n**Position:**\n" .. pos .. "\n\n**GitHub Issue:**\n" .. parse.html_url,
			}}
		})

		if json == nil then
			return false
		else
			http.fetch({
				url = webhook_url,
				method = "POST",
				extra_headers = {"Content-Type: Application/JSON"},
				data = json,
			}, function() end)
			return true
		end
	end)
end

minetest.register_chatcommand("report", {
	params = "<message>",
	description = "Report a bug",
	privs = {interact = true},
	func = function(name, params)
		minetest.log("action", "[/report] executed by '" .. name .. "' with param '" .. (params or "") .. "'")
		local param = params:trim()
		if param == "" then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", S("Error: You have to provide a report text.")))
			return
		end
		if not test_json(name, param) then
			minetest.chat_send_player(name, minetest.colorize("#FF0000",  S("Error: Creating report failed. You are using illegal characters and/or symbols.")))
			return
		end
		send_report(name, param)
		minetest.chat_send_player(name, minetest.colorize("#00BD00", S("Report successfully created.")))
	end,
})