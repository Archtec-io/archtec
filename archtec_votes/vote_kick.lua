-- vote_kick
local pending = {}

local function run_vote(name, param)
	discord.send(nil, ":warning: **" .. name .. "** started a voting: Kick " .. param)
	vote.new_vote(name, {
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
				minetest.chat_send_all("Vote passed, " .. minetest.colorize("#088A08", #results.yes) .. " to " .. minetest.colorize("#FF0000", #results.no) .. ", " .. self.name .. " will be kicked.")
				discord.send(nil, ":warning: Vote passed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " will be kicked.")
				xban.ban_player(self.name, "/vote_kick", os.time() + 3600, "vote-kicked")
			else
				minetest.chat_send_all("Vote failed, " .. minetest.colorize("#088A08", #results.yes) .. " to " .. minetest.colorize("#FF0000", #results.no) .. ", " .. self.name .. " remains ingame.")
				discord.send(nil, ":warning: Vote failed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " remains ingame.")
			end
		end,

		on_vote = function(self, name, value)
			if value == "yes" then
				minetest.chat_send_all(name .. " voted " .. minetest.colorize("#088A08", "YES") .. " to " .. self.description)
				discord.send(nil, ":green_square: **" .. name .. "** voted YES")
			else
				minetest.chat_send_all(name .. " voted " .. minetest.colorize("#FF0000", "NO") .. " to " .. self.description)
				discord.send(nil, ":red_square: **" .. name .. "** voted NO")
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
		if param then param = param:trim() end

		if not minetest.get_player_by_name(param) then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "There is no player called '" .. param .. "'!"))
			return
		end

		if param == name then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't vote-kick yourself!"))
			return
		end

		if minetest.check_player_privs(param, "staff") then
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't vote-kick staff members!"))
			return
		end

		if #minetest.get_connected_players() <= 3 then -- min 4 players
			minetest.chat_send_player(name, minetest.colorize("#FF0000", "Not enough players online to start a vote-kick!"))
			return
		end

		local formspec = {
			"formspec_version[4]",
			"size[8,4]",
			"label[1,0.5;", minetest.formspec_escape("Warning: Abusing a vote-kick can result in a ban for you!"), "]",
			"button[2,1;4,1;continue;Yes, Continue]",
			"button[2,2.5;4,1;abort;Abort]",
		}
		pending[name] = param
		minetest.show_formspec(name, "archtec_votes:kick", table.concat(formspec, ""))
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "archtec_votes:kick" then return end
	local name = player:get_player_name()
	if fields and fields.abort then
		minetest.close_formspec(name, "archtec_votes:kick")
		pending[name] = nil
		return
	end
	if fields and fields.continue then
		minetest.close_formspec(name, "archtec_votes:kick")
		if pending[name] then -- security
			run_vote(name, pending[name])
			pending[name] = nil
		end
		return
	end
	pending[name] = nil
end)
