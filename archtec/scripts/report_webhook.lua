local http = assert(...)
local webhook_url = minetest.settings:get("archtec.webhook_url")

local function send_report(name, report)
	local player = minetest.get_player_by_name(name)
	local pos = tostring(player:get_pos())
    local json = minetest.write_json({
		embeds = {{
			title = "Report by " .. name .. ":",
			description = report .. "\n\n**Position:**\n" .. pos,
		}}
    })
    if json == nil then
		minetest.log("warning", "[archtec] Failed to create JSON for '/report'. Report parameters: " .. dump(report))
		return false
	else
		http.fetch({
			url = webhook_url,
			method = "POST",
			extra_headers = {"Content-Type: Application/JSON"},
			data = json,
		}, function() end)
		notifyTeam("[archtec] " .. name .. " reported an Issue: " .. report)
		return true
	end
end

if webhook_url == nil then
	minetest.log("warning", "No Discord webhook URL found in the settings. Please specify 'archtec.webhook_url' in the settings. The '/report' command is not available now.")
else
	minetest.register_chatcommand("report", {
		params = "<message>",
		description = "Report a bug",
		privs = {interact = true},
		func = function(name, params)
			local param = params:trim()
			if param ~= "" then
				if send_report(name, param) then
					return true, "Report successfully created."
				else
					return false, "Error: Creating report failed. You are using illegal characters and/or symbols."
				end
			else
				return false, "Error: You have to provide a report text."
			end
		end,
	})
end