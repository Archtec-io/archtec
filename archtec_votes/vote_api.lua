local S = minetest.get_translator("archtec_vote")
local C = minetest.colorize
local vote_id = 0

archtec_votes = {
	active = nil,
}

function archtec_votes.new_vote(creator, voteset)
	if archtec_votes.active == nil then
		archtec_votes.start_vote(voteset, creator)
	elseif creator then
		minetest.chat_send_player(creator, S("Can't start a new vote! A vote is already in progress."))
	end
end

function archtec_votes.start_vote(voteset, creator)
	minetest.log("action", "[archtec_votes] " .. creator .. " started a vote: " .. voteset.description .. " (" .. voteset.help .. ")")
	archtec_votes.active = voteset
	voteset.vote_id = vote_id

	-- Results table
	voteset.results = {
		voted = {creator = true},
		yes = {creator},
		no = {},
	}

	-- Timer for end
	if voteset.duration then
		minetest.after(voteset.duration + 0.1, function()
			archtec_votes.end_vote(voteset)
		end)
	end

	minetest.chat_send_all(creator .. " started a vote: " .. voteset.description .. C("#999", " (" .. voteset.help .. ")"))

	-- Handle autovotes
	if voteset.description == "Make day" then
		local names = {}
		for _, player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local val = archtec_playerdata.get(name, "s_avd")
			if val == true and name ~= creator then
				voteset.results.voted[name] = true
				table.insert(voteset.results["yes"], name)
				table.insert(names, name)
			end
		end

		local namestr = table.concat(names, ", ")
		if #names > 0 then
			minetest.chat_send_all(S("Auto-vote @1 by @2.", C("#00BD00", "YES"), namestr))
			minetest.log("action", "[archtec_votes] Auto-vote 'YES' by " .. namestr .. " (" .. #names .. "x)")
		end
	end

	archtec_votes.check_vote(voteset)
end

function archtec_votes.end_vote(voteset)
	if archtec_votes.active == nil or archtec_votes.active.vote_id ~= voteset.vote_id then
		return
	end

	local result
	local total = #voteset.results.yes + #voteset.results.no
	local perc_needed = voteset.perc_needed or 0.5

	if #voteset.results.yes / total > perc_needed then
		result = "yes"
	else
		result = "no"
	end

	minetest.log("action", "[archtec_votes] Vote '" .. voteset.description .. "' ended with result '" .. result .. "'")
	if voteset.on_result then
		voteset:on_result(result, voteset.results)
	end

	vote_id = vote_id + 1
	archtec_votes.active = nil
end

function archtec_votes.check_vote(voteset)
	local all_players_voted = true
	local players = minetest.get_connected_players()
	for _, player in ipairs(players) do
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
		if archtec_votes.active == nil then
			minetest.chat_send_player(name, C("#FF0000", "There is no vote in progress!"))
		end
		archtec_votes.active = nil
		minetest.chat_send_all(C("#FF0000", name .. " canceled active vote!"))
		minetest.log("action", "[archtec_votes] " .. name .. " canceled active vote")
	end
})

-- Vote /y and /n functions
local function vote_yes(name)
	local voteset = archtec_votes.active
	if not voteset then
		minetest.chat_send_player(name, S("There is no vote currently running!"))
		return
	elseif voteset.voted[name] then
		minetest.chat_send_player(name, S("You've already voted!"))
		return
	end
	archtec_votes.vote(voteset, name, "yes")
end

local function vote_no(name)
	local voteset = archtec_votes.active
	if not voteset then
		minetest.chat_send_player(name, S("There is no vote currently running!"))
		return
	elseif voteset.voted[name] then
		minetest.chat_send_player(name, S("You've already voted!"))
		return
	end
	archtec_votes.vote(voteset, name, "no")
end

minetest.register_chatcommand("yes", {
	description = "Vote yes",
	privs = {interact = true},
	func = vote_yes
})
archtec.register_chatcommand_alias("y", "yes")

minetest.register_chatcommand("no", {
	description = "Vote no",
	privs = {interact = true},
	func = vote_no
})
archtec.register_chatcommand_alias("n", "no")
