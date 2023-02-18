local http = minetest.request_http_api()

archtec_matterbridge = {
	-- settings
	url = minetest.settings:get("archtec_matterbridge.url") or "http://127.0.0.1:4242",
	token = minetest.settings:get("archtec_matterbridge.token"),

	-- staff user discord ID's
	allowed_users = {
		Niklp = "880453609530212352",
		LonnySophie = "882021148186009620",
		HomerJayS = "751543903940903034",
		Juri = "298742788865130498"
	}
}

function archtec_matterbridge.staff_user(name, id)
	if archtec_matterbridge.allowed_users[name] == id then
		return true
	end
	return false
end

local MP = minetest.get_modpath("archtec_matterbridge")

if http and archtec_matterbridge.token then
	-- load web stuff
	print("[archtec_matterbridge] connecting to proxy-endpoint at: " .. archtec_matterbridge.url)

	discord = {}

	loadfile(MP .. "/tx.lua")(http)
	loadfile(MP .. "/rx.lua")(http)
end
