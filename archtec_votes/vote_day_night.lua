local function is_night()
	return minetest.get_timeofday() < 0.2 or minetest.get_timeofday() > 0.75
end

minetest.register_chatcommand("vote_day", {
	privs = {interact = true},
	func = function(name)
        if not is_night() then
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't start a new vote, it's already day!"))
            return
        end

        local player = minetest.get_player_by_name(name)
        local inv = player:get_inventory()

        if inv:contains_item("main", "ethereal:etherium_dust 3") then
            inv:remove_item("main", "ethereal:etherium_dust 3")
        else
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "To start a vote you must have 3 etherium dust in your inventory"))
            return
        end

        vote.new_vote(name, {
            description = "Make day",
            help = "/yes or /no",
            name = nil,
            duration = 30,
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
        if is_night() then
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "You can't start a new vote, it's already night!"))
            return
        end

        local player = minetest.get_player_by_name(name)
        local inv = player:get_inventory()

        if inv:contains_item("main", "ethereal:etherium_dust 3") then
            inv:remove_item("main", "ethereal:etherium_dust 3")
        else
            minetest.chat_send_player(name, minetest.colorize("#FF0000", "To start a vote you must have 3 etherium dust in your inventory"))
            return
        end

        vote.new_vote(name, {
            description = "Make night",
            help = "/yes or /no",
            name = nil,
            duration = 30,
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