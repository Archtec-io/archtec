-- vote_kick
local pending = {}
local S = minetest.get_translator(minetest.get_current_modname())
local FS = function(...) return minetest.formspec_escape(S(...)) end
local C = minetest.colorize

local function run_vote(name, param)
	archtec_matterbridge.send(":warning: **" .. name .. "** started a voting: Kick " .. param)
	archtec_votes.new_vote(name, {
		description = "Kick " .. param,
		help = "/yes or /no",
		name = param,
		duration = 60,
		perc_needed = 0.8,

		on_result = function(self, _, results)
			local pcount, result = #minetest.get_connected_players()
			for i = pcount - #results.yes - #results.no, 1, -1 do
				table.insert(results["no"], "")
			end

			if #results.yes / pcount > 0.8 then
				result = "yes"
			else
				result = "no"
			end

			if result == "yes" then
				minetest.chat_send_all("Vote passed, " .. minetest.colorize("#00BD00", #results.yes) .. " to " .. minetest.colorize("#FF0000", #results.no) .. ", " .. self.name .. " will be kicked.")
				archtec_matterbridge.send(":warning: Vote passed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " will be kicked.")
				xban.ban_player(self.name, "/vote_kick", os.time() + 3600, "vote-kicked")
			else
				minetest.chat_send_all("Vote failed, " .. minetest.colorize("#00BD00", #results.yes) .. " to " .. minetest.colorize("#FF0000", #results.no) .. ", " .. self.name .. " remains ingame.")
				archtec_matterbridge.send(":warning: Vote failed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " remains ingame.")
			end
		end,

		on_vote = function(self, name_voter, value)
			if value == "yes" then
				minetest.chat_send_all(name_voter .. " voted " .. minetest.colorize("#00BD00", "YES") .. " to " .. self.description .. ".")
				archtec_matterbridge.send(":green_square: **" .. name_voter .. "** voted YES")
			else
				minetest.chat_send_all(name_voter .. " voted " .. minetest.colorize("#FF0000", "NO") .. " to " .. self.description .. ".")
				archtec_matterbridge.send(":red_square: **" .. name_voter .. "** voted NO")
			end
		end
	})
end

minetest.register_chatcommand("vote_kick", {
	params = "<name>",
	description = "Vote kick someone. Warning: Abusing '/vote_kick' will result in a ban for you",
	privs = {
		interact = true
	},
	func = function(name, param)
		local target = archtec.get_and_trim(param)

		if not archtec.is_online(target) then
			minetest.chat_send_player(name, C("#FF0000", S("[vote-kick] Player '@1' isn't online!", target)))
			return
		end

		if target == name then
			minetest.chat_send_player(name, C("#FF0000", S("[vote-kick] You can't vote-kick yourself!")))
			return
		end

		if minetest.get_player_privs(target).staff then
			minetest.chat_send_player(name, C("#FF0000", S("[vote-kick] You can't vote-kick staff members!")))
			return
		end

		if #minetest.get_connected_players() < 4 then -- min 4 players
			minetest.chat_send_player(name, C("#FF0000", S("Not enough players online to start a vote-kick!")))
			return
		end

		local formspec = [[
			formspec_version[4]
			size[8,4]
			label[1,0.5;]] .. FS("Warning: Abusing a vote-kick can result in a ban for you!") .. [[]
			button[2,1;4,1;continue;]] .. FS("Yes, Continue") .. [[]
			button[2,2.5;4,1;abort;]] .. FS("Abort") .. [[]
		]]
		pending[name] = target
		minetest.show_formspec(name, "archtec_votes:kick", formspec)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec_votes:kick" then return end
	local name = player:get_player_name()
	if fields.abort then
		minetest.close_formspec(name, "archtec_votes:kick")
	end

	if fields.continue then
		minetest.close_formspec(name, "archtec_votes:kick")
		if pending[name] and archtec.is_online(pending[name]) then
			run_vote(name, pending[name])
		end
	end

	pending[name] = nil
	return true
end)
