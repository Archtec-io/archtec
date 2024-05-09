local http = assert(...)
local S = archtec.S
local F = minetest.formspec_escape
local FS = function(...)
	return F(S(...))
end
local C = minetest.colorize

local webhook_url = minetest.settings:get("archtec.webhook_url")
local report_gpg_key = minetest.settings:get("archtec.report_gpg_key")
local report_max_length = 500

if not report_gpg_key or not webhook_url then
	error("[archtec] No report keys found!")
end

local function clean_meta(m)
	local meta = table.copy(m)
	if meta.fields.ui_waypoints then -- waypoints may contain private data
		meta.fields.ui_waypoints = nil
	end
	return meta
end

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

-- GitHub issue creator
local function send_report(name, report)
	local player = minetest.get_player_by_name(name)
	local data = {pos = "unknown", pos_string = "unknown", meta = "unknown"}

	if player then
		local pos = player:get_pos()
		local pos_r = vector.round(pos)
		data.pos = dump(pos)
		data.pos_string = pos_r.x .. "," .. pos_r.y .. "," .. pos_r.z
		data.meta = dump(clean_meta(player:get_meta():to_table()))
	end

	local body = {
		"**Report by " .. name .. ":**",
		report .. "\n",
		"**Position:**",
		"```\n" .. data.pos .. "\n```",
		"**Meta:**",
		"```\n" .. data.meta .. "\n```",
		"**Server status:**",
		"```\n" .. minetest.get_server_status() .. "\n```",
		"**Teleport command:**",
		"```\n" .. "/teleport " .. data.pos_string .. "\n```",
	}

	local json = minetest.write_json({
		title = "Report by " .. name .. ": " .. create_title(report),
		body = table.concat(body, "\n"),
	})

	if json == nil then
		minetest.log("error", "[archtec] Failed to create json for report '" .. table.concat(body, "\n") .. "'")
		return false
	end

	http.fetch({
		url = "https://api.github.com/repos/Archtec-io/bugtracker/issues",
		method = "POST",
		extra_headers = {
			"Accept: application/vnd.github+json",
			"Authorization: Bearer " .. report_gpg_key,
			"X-GitHub-Api-Version: 2022-11-28",
		},
		data = json,
	}, function(res)
		local parse = minetest.parse_json(res.data)
		if parse.html_url then
			archtec.notify_team("[archtec] " .. name .. " reported an Issue: " .. report .. " URL: " .. parse.html_url)
		else
			archtec.notify_team(
				"[archtec] "
					.. name
					.. " reported an Issue: "
					.. report
					.. " URL: unknown (JSON parsing error) | Response code: "
					.. (res.code or "unknown")
			)
		end

		if not parse.html_url then
			parse.html_url = "Unknown URL"
		end
		minetest.chat_send_player(
			name,
			C("#00BD00", S("[report] Report successfully created. GitHub URL: @1", parse.html_url))
		)

		-- Discord webhook
		local body_dc = {
			report .. "\n",
			"**Position:**",
			"/teleport " .. data.pos_string .. "\n",
			"**GitHub Issue:**",
			parse.html_url,
		}

		local json_dc = minetest.write_json({
			embeds = {{
				title = "Report by " .. name .. ":",
				description = table.concat(body_dc, "\n"),
			}},
		})

		if json_dc ~= nil then
			http.fetch({
				url = webhook_url,
				method = "POST",
				extra_headers = {"Content-Type: Application/JSON"},
				data = json_dc,
			}, function() end)
		end
	end)
end

-- Report formspec
archtec_playerdata.register_key("report_draft", "string", "")

local function report_formspec(name)
	local draft = archtec_playerdata.get(name, "report_draft")

	local formspec = {
		"formspec_version[3]",
		"size[11,8.2]",
		"box[0.3,0.3;10.4,0.5;#c6e8ff]",
		"label[0.4,0.55;" .. FS("Report issue/Send feature request") .. "]",
		"textarea[0.3,1.1;10.4,5;report_text;;" .. F(draft) .. "]",
		"label[0.3,6.4;" .. FS("Max. number of characters: @1", report_max_length) .. "]",
		"label[0.3,6.8;" .. FS("Your report will be saved as an public viewable issue on GitHub.") .. "]",
		"button[0.3,7.1;3,0.8;draft_delete;" .. FS("Delete draft") .. "]",
		"button[4.0,7.1;3,0.8;draft_save;" .. FS("Save draft") .. "]",
		"style[report_send;bgcolor=green]",
		"button[7.7,7.1;3,0.8;report_send;" .. FS("Send report") .. "]",
	}

	minetest.show_formspec(name, "archtec:report", table.concat(formspec))
end

local function check_text(text)
	if #text > report_max_length then
		return false
	end
	local json = minetest.write_json({title = text})
	if json == nil then
		return false
	end
	return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec:report" or fields.quit then
		return
	end
	local name = player:get_player_name()

	if not check_text(fields.report_text) then
		minetest.close_formspec(name, "archtec:report")
		minetest.chat_send_player(
			name,
			C("#FF0000", S("[report] Your text is too long and/or contains disallowed characters!"))
		)
		return true
	end

	if fields.draft_save then
		archtec_playerdata.set(name, "report_draft", fields.report_text)
	end

	if fields.draft_delete then
		archtec_playerdata.set(name, "report_draft", "")
	end

	if fields.report_send then
		send_report(name, fields.report_text)
		archtec_playerdata.set(name, "report_draft", "")
		minetest.close_formspec(name, "archtec:report")
		return true
	end

	report_formspec(name)
	return true
end)

minetest.register_chatcommand("report", {
	params = "",
	description = "Report a bug/feature request",
	privs = {interact = true},
	func = function(name, param)
		minetest.log("action", "[/report] executed by '" .. name .. "' with param '" .. param .. "'")
		local text = archtec.get_and_trim(param)
		if text ~= "" and archtec_playerdata.get(name, "report_draft") == "" and check_text(text) then
			archtec_playerdata.set(name, "report_draft", text)
		end
		report_formspec(name)
	end,
})
