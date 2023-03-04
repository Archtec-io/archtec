--vote_kick
minetest.register_chatcommand("vote_kick", {
	params = "<name>",
	description = "Vote kick someone. Warning: Abusing '/vote_kick' will result in a ban for you",
	privs = {
		interact = true
	},
	func = function(name, param)
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

		discord.send(nil, ":warning: **" .. name .. "** started a voting: Kick " .. param)
		vote.new_vote(name, {
			description = "Kick " .. param,
			help = "/yes or /no",
			name = param,
			duration = 60,
			perc_needed = 0.8,

			on_result = function(self, result, results)
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
})