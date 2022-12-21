vote = {
	active = {},
	queue = {}
}

function vote.new_vote(creator, voteset)
	local max_votes = 1

	if #vote.active < max_votes then
		vote.start_vote(voteset)
		vote.vote(voteset, creator, "yes")
	else
		table.insert(vote.queue, voteset)
		if creator then
			minetest.chat_send_player(creator, "Vote queued until there is less then " .. max_votes .. " votes active.")
		end
	end
end

function vote.start_vote(voteset)
	minetest.log("action", "Vote started: " .. voteset.description)
	table.insert(vote.active, voteset)

	-- Build results table
	voteset.results = {
		abstain = {},
		voted = {}
	}

	if voteset.options then
		for _, option in pairs(voteset.options) do
			voteset.results[option] = {}
			print(" - " .. option)
		end
	else
		voteset.results.yes = {}
		voteset.results.no = {}
	end

	-- Run start callback
	if voteset.on_start then
		voteset:on_start()
	end

	-- Timer for end
	if voteset.duration or voteset.time then
		minetest.after(voteset.duration + 0.1, function()
			vote.end_vote(voteset)
		end)
	end

	minetest.chat_send_all("Vote started: " .. voteset.description)
end

function vote.end_vote(voteset)
	local removed = false
	for i, voteset2 in pairs(vote.active) do
		if voteset == voteset2 then
			table.remove(vote.active, i, 1)
			removed = true
		end
	end
	if not removed then
		return
	end

	local result = nil
	if voteset.on_decide then
		result = voteset:on_decide(voteset.results)
	elseif voteset.results.yes and voteset.results.no then
		local total = #voteset.results.yes + #voteset.results.no
		local perc_needed = voteset.perc_needed or 0.5

		if #voteset.results.yes / total > perc_needed then
			result = "yes"
		else
			result = "no"
		end
	end

	minetest.log("action", "Vote '" .. voteset.description .. "' ended with result '" .. result .. "'.")
	if voteset.on_result then
		voteset:on_result(result, voteset.results)
	end

	local max_votes = 1
	if #vote.active < max_votes and #vote.queue > 0 then
		local nextvote = table.remove(vote.queue, 1)
		vote.start_vote(nextvote)
	end
end

function vote.get_next_vote(name)
	for _, voteset in pairs(vote.active) do
		if not voteset.results.voted[name] then
			return voteset
		end
	end
	return nil
end

function vote.check_vote(voteset)
	local all_players_voted = true
	local players = minetest.get_connected_players()
	for _, player in pairs(players) do
		local name = player:get_player_name()
		if not voteset.results.voted[name] then
			all_players_voted = false
			break
		end
	end

	if all_players_voted then
		vote.end_vote(voteset)
	end
end

function vote.vote(voteset, name, value)
	if not voteset.results[value] then
		return
	end

	minetest.log("action", name .. " voted '" .. value .. "' to '" .. voteset.description .. "'")

	table.insert(voteset.results[value], name)
	voteset.results.voted[name] = true
	if voteset.on_vote then
		voteset:on_vote(name, value)
	end
	vote.check_vote(voteset)
end

--register commands
minetest.register_chatcommand("vote_clear", {
	privs = {
		staff = true,
	},
	func = function(name, params)
		vote.active = {}
		vote.queue = {}
		minetest.chat_send_all(name .. " canceled all active votes!")
		minetest.log("action", "[archtec_votes] " .. name .. " canceled all active votes!")
	end
})

local function vote_yes(name, params)
	local voteset = vote.get_next_vote(name)
	if not voteset then
		minetest.chat_send_player(name, "There is no vote currently running!")
		return
	elseif not voteset.results.yes then
		minetest.chat_send_player(name, "The vote is not a y/n one.")
		return
	elseif voteset.can_vote and not voteset:can_vote(name) then
		minetest.chat_send_player(name, "You can't vote in the currently active vote!")
		return
	end
	vote.vote(voteset, name, "yes")
end

minetest.register_chatcommand("yes", {
	privs = {interact = true},
	func = vote_yes
})

minetest.register_chatcommand("y", {
	privs = {interact = true},
	func = vote_yes
})

local function vote_no(name, params)
	local voteset = vote.get_next_vote(name)
	if not voteset then
		minetest.chat_send_player(name, "There is no vote currently running!")
		return
	elseif not voteset.results.no then
		minetest.chat_send_player(name, "The vote is not a yes/no one.")
		return
	elseif voteset.can_vote and not voteset:can_vote(name) then
		minetest.chat_send_player(name, "You can't vote in the currently active vote!")
		return
	end
	vote.vote(voteset, name, "no")
end

minetest.register_chatcommand("no", {
	privs = {interact = true},
	func = vote_no
})

minetest.register_chatcommand("n", {
	privs = {interact = true},
	func = vote_no
})
