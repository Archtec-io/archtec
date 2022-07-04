local http = assert(...)
local webhook_url = minetest.settings:get("archtec.webhook_url")

local function send_webhook(player_name, report)
    local data = minetest.write_json({
        embeds = {
            {
                title = "Report from " .. player_name,
                description = report
            }
        }
    })
    http.fetch({
        url = webhook_url,
        method = "POST",
        extra_headers = {"Content-Type: application/json"},
        data = data,
        post_data = data
    }, function() end)
end

minetest.register_chatcommand("report", {
    privs = {interact=true},
    func = function(name, param)
        send_webhook(name, param)
        minetest.chat_send_player(name, "Report created successfully")
        return
    end,
})