local S = core.get_translator(core.get_current_modname())
local C = core.colorize

local function is_night()
	return core.get_timeofday() < 0.2 or core.get_timeofday() > 0.75
end

local free_votes = 5
archtec.free_votes = free_votes
archtec_playerdata.register_key("free_votes", "number", 0)

core.register_chatcommand("vote_day", {
	description = "Start a vote to set the time to day",
	privs = {interact = true},
	func = function(name)
		if not is_night() then
			core.chat_send_player(name, C("#FF0000", S("You can't start a new vote, it's already day!")))
			return
		end

		local player = core.get_player_by_name(name)
		local inv = player:get_inventory()

		if inv:contains_item("main", "ethereal:etherium_dust 3") then
			inv:remove_item("main", "ethereal:etherium_dust 3")
		elseif archtec_playerdata.get(name, "free_votes") < free_votes then
			archtec_playerdata.mod(name, "free_votes", 1)
			local counter = free_votes - archtec_playerdata.get(name, "free_votes")
			core.chat_send_player(name, C("#00BD00", S("Used one of your free votes, remaning free votes: @1.", counter)))
		else
			core.chat_send_player(name, C("#FF0000", S("To start a vote you must have 3 etherium dust in your inventory!")))
			return
		end

		archtec_votes.new_vote(name, {
			description = "Make day",
			help = "/yes or /no",
			name = nil,
			duration = 20,
			perc_needed = 0.6,

			on_result = function(self, result, results)
				if result == "yes" then
					core.chat_send_all("Vote passed, " .. C("#00BD00", #results.yes) .. " to " .. C("#FF0000", #results.no) .. ", Time will be set to day.")
					core.set_timeofday(0.23) -- same as beds
				else
					core.chat_send_all("Vote failed, " .. C("#00BD00", #results.yes) .. " to " .. C("#FF0000", #results.no) .. ", Time won't be set to day.")
				end
			end,

			on_vote = function(self, name_voter, value)
				if value == "yes" then
					core.chat_send_all(name_voter .. " voted " .. C("#00BD00", "YES") .. " to " .. self.description .. ".")
				else
					core.chat_send_all(name_voter .. " voted " .. C("#FF0000", "NO") .. " to " .. self.description .. ".")
				end
			end
		})
	end
})
archtec.register_chatcommand_alias("vd", "vote_day")

core.register_chatcommand("vote_night", {
	description = "Start a vote to set the time to night",
	privs = {interact = true},
	func = function(name)
		if is_night() then
			core.chat_send_player(name, C("#FF0000", S("You can't start a new vote, it's already night!")))
			return
		end

		local player = core.get_player_by_name(name)
		local inv = player:get_inventory()

		if inv:contains_item("main", "ethereal:etherium_dust 3") then
			inv:remove_item("main", "ethereal:etherium_dust 3")
		elseif archtec_playerdata.get(name, "free_votes") < free_votes then
			archtec_playerdata.mod(name, "free_votes", 1)
			local counter = free_votes - archtec_playerdata.get(name, "free_votes")
			core.chat_send_player(name, C("#00BD00", S("Used one of your free votes, remaning free votes: @1!", counter)))
		else
			core.chat_send_player(name, C("#FF0000", S("To start a vote you must have 3 etherium dust in your inventory.")))
			return
		end

		archtec_votes.new_vote(name, {
			description = "Make night",
			help = "/yes or /no",
			name = nil,
			duration = 20,
			perc_needed = 0.6,

			on_result = function(self, result, results)
				if result == "yes" then
					core.chat_send_all("Vote passed, " .. C("#00BD00", #results.yes) .. " to " .. C("#FF0000", #results.no) .. ", Time will be set to night.")
					core.set_timeofday(0)
				else
					core.chat_send_all("Vote failed, " .. C("#00BD00", #results.yes) .. " to " .. C("#FF0000", #results.no) .. ", Time won't be set to night.")
				end
			end,

			on_vote = function(self, name_voter, value)
				if value == "yes" then
					core.chat_send_all(name_voter .. " voted " .. C("#00BD00", "YES") .. " to " .. self.description .. ".")
				else
					core.chat_send_all(name_voter .. " voted " .. C("#FF0000", "NO") .. " to " .. self.description .. ".")
				end
			end
		})
	end
})
archtec.register_chatcommand_alias("vn", "vote_night")
