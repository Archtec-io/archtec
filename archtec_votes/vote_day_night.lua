minetest.register_chatcommand("vote_day", {
	privs = {interact = true},
	func = function(name)
        vote.new_vote(name, {
            description = "Make day",
            help = "/yes,  /no  or  /abstain",
            name = nil,
            duration = 60,
            perc_needed = 0.6,

            on_result = function(self, result, results)
                if result == "yes" then
                    minetest.chat_send_all("Vote passed, " .. #results.yes .. " to " .. #results.no .. ", Time will be set to day")
                    minetest.set_timeofday(0.3)
                else
                    minetest.chat_send_all("Vote failed, " .. #results.yes .. " to " .. #results.no .. ", Time won't be set to day")
                end
            end,

            on_vote = function(self, name, value)
                if value == "yes" then
                    minetest.chat_send_all(name .. " voted " .. minetest.colorize("#088A08", "YES") .. " to " .. self.description)
                else
                    minetest.chat_send_all(name .. " voted " .. minetest.colorize("#FF0000", "NO") .. " to " .. self.description)
                end
            end
        })
    end
})

minetest.register_chatcommand("vote_night", {
	privs = {interact = true},
	func = function(name)
        vote.new_vote(name, {
            description = "Make night",
            help = "/yes,  /no  or  /abstain",
            name = nil,
            duration = 60,
            perc_needed = 0.6,

            on_result = function(self, result, results)
                if result == "yes" then
                    minetest.chat_send_all("Vote passed, " .. #results.yes .. " to " .. #results.no .. ", Time will be set to night")
                    minetest.set_timeofday(0)
                else
                    minetest.chat_send_all("Vote failed, " .. #results.yes .. " to " .. #results.no .. ", Time won't be set to night")
                end
            end,

            on_vote = function(self, name, value)
                if value == "yes" then
                    minetest.chat_send_all(name .. " voted " .. minetest.colorize("#088A08", "YES") .. " to " .. self.description)
                else
                    minetest.chat_send_all(name .. " voted " .. minetest.colorize("#FF0000", "NO") .. " to " .. self.description)
                end
            end
        })
    end
})