local S = core.get_translator("archtec_vote")
local C = core.colorize
local vote_id = 0

archtec_votes = {
	active = nil,
}

function archtec_votes.new_vote(creator, voteset)
	if archtec_votes.active == nil then
		archtec_votes.start_vote(voteset, creator)
	elseif creator then
		core.chat_send_player(creator, C("#FF0000", S("Can't start a new vote! A vote is already in progress.")))
	end
end

function archtec_votes.start_vote(voteset, creator)
	core.log("action", "[archtec_votes] " .. creator .. " started a vote: " .. voteset.description .. " (" .. voteset.help .. ")")
	archtec_votes.active = voteset
	voteset.vote_id = vote_id

	-- Results table
	voteset.results = {
		voted = {[creator] = true},
		yes = {creator},
		no = {},
	}

	-- Timer for end
	if voteset.duration then
		core.after(voteset.duration + 0.1, function()
			archtec_votes.end_vote(voteset)
		end)
	end

	core.chat_send_all(S("@1 started a vote: @2 (@3)", creator, voteset.description, C("#999", voteset.help)))

	-- Handle autovotes
	if voteset.description == "Make day" then
		local names = {}
		for _, player in ipairs(core.get_connected_players()) do
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
			core.chat_send_all(S("Auto-vote @1 by @2.", C("#00BD00", "YES"), namestr))
			core.log("action", "[archtec_votes] Auto-vote 'YES' by " .. namestr .. " (" .. #names .. "x)")
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

	core.log("action", "[archtec_votes] Vote '" .. voteset.description .. "' ended with result '" .. result .. "'")
	if voteset.on_result then
		voteset:on_result(result, voteset.results)
	end

	vote_id = vote_id + 1
	archtec_votes.active = nil
end

function archtec_votes.check_vote(voteset)
	local all_players_voted = true
	local players = core.get_connected_players()
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
	core.log("action", "[archtec_votes] " .. name .. " voted '" .. value .. "' to '" .. voteset.description .. "'")

	table.insert(voteset.results[value], name)
	voteset.results.voted[name] = true
	if voteset.on_vote then
		voteset:on_vote(name, value)
	end
	archtec_votes.check_vote(voteset)
end

-- Register commands
core.register_chatcommand("vote_clear", {
	description = "Clear the active vote",
	privs = {staff = true},
	func = function(name)
		if archtec_votes.active == nil then
			core.chat_send_player(name, C("#FF0000", S("There is no vote in progress!")))
		end
		archtec_votes.active = nil
		core.chat_send_all(C("#FF0000", S("@1 canceled active vote!", name)))
		core.log("action", "[archtec_votes] " .. name .. " canceled active vote")
	end
})

-- Vote /y and /n functions
local function vote_yes(name)
	local voteset = archtec_votes.active
	if not voteset then
		core.chat_send_player(name, C("#FF0000", S("There is no vote currently running!")))
		return
	elseif voteset.results.voted[name] then
		core.chat_send_player(name, C("#FF0000", S("You've already voted!")))
		return
	end
	archtec_votes.vote(voteset, name, "yes")
end

local function vote_no(name)
	local voteset = archtec_votes.active
	if not voteset then
		core.chat_send_player(name, C("#FF0000", S("There is no vote currently running!")))
		return
	elseif voteset.results.voted[name] then
		core.chat_send_player(name, C("#FF0000", S("You've already voted!")))
		return
	end
	archtec_votes.vote(voteset, name, "no")
end

core.register_chatcommand("yes", {
	description = "Vote yes",
	privs = {interact = true},
	func = vote_yes
})
archtec.register_chatcommand_alias("y", "yes")

core.register_chatcommand("no", {
	description = "Vote no",
	privs = {interact = true},
	func = vote_no
})
archtec.register_chatcommand_alias("n", "no")
