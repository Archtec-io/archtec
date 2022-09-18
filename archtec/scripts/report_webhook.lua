local http = assert(...)
local webhook_url = minetest.settings:get("archtec.webhook_url")

local function send_report(name, report)
    local json = minetest.write_json({
		embeds = {{
			title = "Report by "..name..":",
			description = report
		}}
    })
    if json == nil then
		minetest.log("warning", "Failed to create JSON for '/report'. Report parameters: "..dump(report))
		return false
	else
		http.fetch({
			url = webhook_url,
			method = "POST",
			extra_headers = { "Content-Type: Application/JSON" },
			data = json,
		}, function() end)
		local logMessage = "[archtec] " .. name .. " reported an Issue: " .. report
		notifyTeam(minetest.colorize("#666", logMessage))
		return true
	end
end

minetest.register_chatcommand("report", {
	privs = { interact = true },
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