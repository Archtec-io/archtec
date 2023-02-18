--vote_kick
minetest.register_chatcommand("vote_kick", {
	privs = {
		interact = true
	},
	func = function(name, param)
		if not minetest.get_player_by_name(param) then
			minetest.chat_send_player(name, "There is no player called '" .. param .. "'")
			return
		end

		if param == name then
			minetest.chat_send_player(name, "You can't vote-kick yourself!")
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
					minetest.chat_send_all("Vote passed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " will be kicked.")
					minetest.kick_player(self.name, "The vote to kick you passed")
					discord.send(nil, "Vote passed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " will be kicked.")
					xban.ban_player(name, "/vote_kick", os.time() + 3600, "vote-kicked")
				else
					minetest.chat_send_all("Vote failed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " remains ingame.")
					discord.send(nil, "Vote failed, " .. #results.yes .. " to " .. #results.no .. ", " .. self.name .. " remains ingame.")
				end
			end,

			on_vote = function(self, name, value)
				minetest.chat_send_all(name .. " voted " .. value .. " to '" .. self.description .. "'")
				if value == "yes" then
					discord.send(nil, ":green_square: **" .. name .. "** voted YES")
				else
					discord.send(nil, ":red_square: **" .. name .. "** voted NO")
				end
			end
		})
	end
})