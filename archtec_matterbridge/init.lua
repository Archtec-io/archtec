local http = core.request_http_api()
local MP = core.get_modpath("archtec_matterbridge")

archtec_matterbridge = {
	-- settings
	url = core.settings:get("archtec_matterbridge.url") or "http://127.0.0.1:4242",
	token = core.settings:get("archtec_matterbridge.token"),

	-- staff user discord ID's
	allowed_users = {
		Niklp = "880453609530212352",
		LonnySophie = "882021148186009620",
		HomerJayS = "751543903940903034",
		Juri = "298742788865130498"
	},

	emojis = dofile(MP .. "/emoji.lua")
}

if not archtec_matterbridge.token then
	error("[archtec_matterbridge] No token provided!")
end

function archtec_matterbridge.staff_user(name, id)
	if archtec_matterbridge.allowed_users[name] == id then
		return true
	end
	return false
end

if http and archtec_matterbridge.token then
	core.log("action", "[archtec_matterbridge] connecting to matterbridge at: " .. archtec_matterbridge.url)

	loadfile(MP .. "/tx.lua")(http)
	loadfile(MP .. "/rx.lua")(http)
end
