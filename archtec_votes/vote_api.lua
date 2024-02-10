local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
archtec_votes = {
	active = {},
}

function archtec_votes.new_vote(creator, voteset)
	if #archtec_votes.active < 1 then
		archtec_votes.start_vote(voteset, creator)
		-- vote "yes"
		table.insert(voteset.results["yes"], creator)
		voteset.results.voted[creator] = true
		archtec_votes.check_vote(voteset)

		-- Handle autovotes
		if voteset.description == "Make day" then
			local names = {}
			for _, player in ipairs(minetest.get_connected_players()) do
				local name = player:get_player_name()
				local val = archtec_playerdata.get(name, "s_avd")
				if val == true and name ~= creator then
					table.insert(voteset.results["yes"], name)
					voteset.results.voted[name] = true
					table.insert(names, name)
				end
			end

			local namestr = table.concat(names, ", ")
			if #names > 0 then
				minetest.chat_send_all(S("Auto-vote @1 by @2.", C("#00BD00", "YES"), namestr))
				minetest.log("action", "[archtec_votes] Auto-vote 'YES' by " .. namestr .. " (" .. #names .. "x)")
				archtec_votes.check_vote(voteset)
			end
		end
	elseif creator then
		minetest.chat_send_player(creator, S("Can't start a new vote! A vote is already in progress."))
	end
end

function archtec_votes.start_vote(voteset, creator)
	minetest.log("action", "[archtec_votes] " .. creator .. " started a vote: " .. voteset.description .. " (" .. voteset.help .. ")")
	table.insert(archtec_votes.active, voteset)

	-- Build results table
	voteset.results = {
		voted = {}
	}

	voteset.results.yes = {}
	voteset.results.no = {}

	-- Run start callback
	if voteset.on_start then
		voteset:on_start()
	end

	-- Timer for end
	if voteset.duration or voteset.time then
		minetest.after(voteset.duration + 0.1, function()
			archtec_votes.end_vote(voteset)
		end)
	end

	minetest.chat_send_all(creator .. " started a vote: " .. voteset.description .. C("#999", " (" .. voteset.help .. ")"))
end

function archtec_votes.end_vote(voteset)
	local removed = false
	for i, voteset2 in pairs(archtec_votes.active) do
		if voteset == voteset2 then
			table.remove(archtec_votes.active, i, 1)
			removed = true
		end
	end
	if not removed then
		return
	end

	local result = nil
	if voteset.results.yes and voteset.results.no then
		local total = #voteset.results.yes + #voteset.results.no
		local perc_needed = voteset.perc_needed or 0.5

		if #voteset.results.yes / total > perc_needed then
			result = "yes"
		else
			result = "no"
		end
	end

	minetest.log("action", "[archtec_votes] Vote '" .. voteset.description .. "' ended with result '" .. result .. "'")
	if voteset.on_result then
		voteset:on_result(result, voteset.results)
	end
end

function archtec_votes.get_next_vote(name)
	-- luacheck: ignore (512)
	for _, voteset in pairs(archtec_votes.active) do
		if not voteset.results.voted[name] then
			return voteset
		end
		return 0 -- false is already used
	end
	return nil
end

function archtec_votes.check_vote(voteset)
	local all_players_voted = true
	local players = minetest.get_connected_players()
	for _, player in pairs(players) do
		local name = player:get_player_name()
		if not voteset.results.voted[name] then
			all_players_voted = false
			break
		end
	end

	-- Trigger vote end when the majority has been established
	local perc_needed = voteset.perc_needed or 0.5
	if (#voteset.results.yes / #players > perc_needed) or (#voteset.results.no / #players > perc_needed) then
		all_players_voted = true
	end

	if all_players_voted then
		archtec_votes.end_vote(voteset)
	end
end

function archtec_votes.vote(voteset, name, value)
	if not voteset.results[value] then
		return
	end

	minetest.log("action", "[archtec_votes] " .. name .. " voted '" .. value .. "' to '" .. voteset.description .. "'")

	table.insert(voteset.results[value], name)
	voteset.results.voted[name] = true
	if voteset.on_vote then
		voteset:on_vote(name, value)
	end
	archtec_votes.check_vote(voteset)
end

-- Register commands
minetest.register_chatcommand("vote_clear", {
	description = "Clear the active vote",
	privs = {staff = true},
	func = function(name)
		if not next(archtec_votes.active) then
			minetest.chat_send_player(name, C("#FF0000", "There are no active votes!"))
		end
		archtec_votes.active = {}
		minetest.chat_send_all(C("#FF0000", name .. " canceled all active votes!"))
		minetest.log("action", "[archtec_votes] " .. name .. " canceled all active votes")
	end
})

-- Vote /y and /n functions

local function vote_yes(name)
	local voteset = archtec_votes.get_next_vote(name)
	if not voteset then
		minetest.chat_send_player(name, S("There is no vote currently running!"))
		return
	elseif voteset == 0 then
		minetest.chat_send_player(name, S("You've already voted!"))
		return
	elseif not voteset.results.yes then
		minetest.chat_send_player(name, S("The vote is not a yes/no one."))
		return
	elseif voteset.can_vote and not voteset:can_vote(name) then
		minetest.chat_send_player(name, S("You can't vote in the currently active vote!"))
		return
	end
	archtec_votes.vote(voteset, name, "yes")
end

minetest.register_chatcommand("yes", {
	description = "Vote yes",
	privs = {interact = true},
	func = vote_yes
})

minetest.register_chatcommand("y", {
	description = "Vote yes",
	privs = {interact = true},
	func = vote_yes
})

local function vote_no(name)
	local voteset = archtec_votes.get_next_vote(name)
	if not voteset then
		minetest.chat_send_player(name, S("There is no vote currently running!"))
		return
	elseif voteset == 0 then
		minetest.chat_send_player(name, S("You've already voted!"))
		return
	elseif not voteset.results.no then
		minetest.chat_send_player(name, S("The vote is not a yes/no one."))
		return
	elseif voteset.can_vote and not voteset:can_vote(name) then
		minetest.chat_send_player(name, S("You can't vote in the currently active vote!"))
		return
	end
	archtec_votes.vote(voteset, name, "no")
end

minetest.register_chatcommand("no", {
	description = "Vote no",
	privs = {interact = true},
	func = vote_no
})

minetest.register_chatcommand("n", {
	description = "Vote no",
	privs = {interact = true},
	func = vote_no
})
