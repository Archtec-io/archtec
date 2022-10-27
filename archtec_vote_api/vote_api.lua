vote = {
	active = {},
	queue = {}
}

function vote.new_vote(creator, voteset)
	local max_votes = 1

	if #vote.active < max_votes then
		vote.start_vote(voteset)
	else
		table.insert(vote.queue, voteset)
		if creator then
			minetest.chat_send_player(creator,
				"Vote queued until there is less then " .. max_votes .. " votes active.")
		end
	end
end

function vote.start_vote(voteset)
	minetest.log("action", "Vote started: " .. voteset.description)
	local logMessage = "[archtec_votes] Vote started: '" .. voteset.description .. "'"
	notifyTeam(minetest.colorize("#666", logMessage))

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

	-- Show HUD a.s.a.p.
	vote.update_all_hud()
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
	local logMessage = "[archtec_votes] Vote '" .. voteset.description .. "' ended with result '" .. result .. "'"
	notifyTeam(minetest.colorize("#666", logMessage))
	if voteset.on_result then
		voteset:on_result(result, voteset.results)
	end

	local max_votes = 1
	if #vote.active < max_votes and #vote.queue > 0 then
		local nextvote = table.remove(vote.queue, 1)
		vote.start_vote(nextvote)
	else
		-- Update HUD a.s.a.p.
		vote.update_all_hud()
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
	local logMessage = "[archtec_votes] '" .. name .. "' voted '" .. value .. "' to '" .. voteset.description .. "'"
	notifyTeam(minetest.colorize("#666", logMessage))

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
		vote.update_all_hud()
	end
})

local hudkit = dofile(minetest.get_modpath("archtec_vote_api") .. "/vote_hudkit.lua")

vote.hud = hudkit()
function vote.update_hud(player)
	local name = player:get_player_name()
	local voteset = vote.get_next_vote(name)
	if not voteset then
		vote.hud:remove(player, "vote:desc")
		vote.hud:remove(player, "vote:bg")
		vote.hud:remove(player, "vote:help")
		return
	end

	if not vote.hud:exists(player, "vote:bg") then
		vote.hud:add(player, "vote:bg", {
			hud_elem_type = "image",
			position = {x = 1, y = 0.5},
			scale = {x = 2, y = 2},
			text = "vote_background.png",
			offset = {x=-100, y = 10},
			number = 0xFFFFFF
		})
	end

	if vote.hud:exists(player, "vote:desc") then
		vote.hud:change(player, "vote:desc", "text", voteset.description .. "?")
	else
		vote.hud:add(player, "vote:desc", {
			hud_elem_type = "text",
			position = {x = 1, y = 0.5},
			scale = {x = 100, y = 100},
			text = voteset.description .. "?",
			offset = {x=-100, y = 0},
			number = 0xFFFFFF
		})
	end

	if voteset.help then
		if vote.hud:exists(player, "vote:help") then
			vote.hud:change(player, "vote:help", "text", voteset.help)
		else
			vote.hud:add(player, "vote:help", {
				hud_elem_type = "text",
				position = {x = 1, y = 0.5},
				scale = {x = 100, y = 100},
				text = voteset.help,
				offset = {x=-100, y = 20},
				number = 0xFFFFFF
			})
		end
	else
		vote.hud:remove(player, "vote:help")
	end
end

minetest.register_on_leaveplayer(function(player)
	vote.hud.players[player:get_player_name()] = nil
end)

function vote.update_all_hud()
	local players = minetest.get_connected_players()
	for _, player in pairs(players) do
		vote.update_hud(player)
	end
end

local timer_gs = 0
minetest.register_globalstep(function(dtime)
	timer_gs = timer_gs + dtime
	if timer_gs < 5 then
		return
	end
	timer_gs = 0

	vote.update_all_hud()
end)

minetest.register_chatcommand("yes", {
	privs = {
		interact = true
	},
	func = function(name, params)
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
})

minetest.register_chatcommand("no", {
	privs = {
		interact = true
	},
	func = function(name, params)
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
})
