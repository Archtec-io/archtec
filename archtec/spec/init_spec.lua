require("mineunit")
mineunit("core")
mineunit("common/misc_helpers")

fixture("archtec")

-- Hack
function string:trim()
	return self:match("^%s*(.-)%s*$")
end

local Sam = Player("Sam")

function join()
	mineunit:execute_on_joinplayer(Sam)
end

function leave()
	mineunit:execute_on_leaveplayer(Sam)
end

-- Test common.lua
describe("common.lua", function()
	-- get_target()
	it("get_target() 1", function()
		assert.is_same("User2", archtec.get_target("User", "User2"))
	end)

	it("get_target() 2", function()
		assert.is_same("User2", archtec.get_target("User", " User2 "))
	end)

	it("get_target() 3", function()
		assert.is_same("User", archtec.get_target("User", ""))
	end)

	it("get_target() 4", function()
		assert.is_same("User", archtec.get_target("User", {}))
	end)

	-- is_online()
	join()
	it("is_online() 1", function()
		assert.is_true(archtec.is_online("Sam"))
	end)

	leave()
	it("is_online() 2", function()
		assert.is_false(archtec.is_online("Sam"))
	end)
end)