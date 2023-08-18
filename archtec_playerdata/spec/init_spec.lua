require("mineunit")
mineunit("core")

fixture("archtec")
sourcefile("init")

-- Simulate join
local Sam = Player("Sam")

-- Players join before tests begin
mineunit:execute_on_joinplayer(Sam)

describe("Test main functions (online player)", function()
	it("get - check default", function()
		assert.is_same(0, archtec_playerdata.get("Sam", "nodes_dug"))
	end)

	it("set - set to 1", function()
		archtec_playerdata.set("Sam", "nodes_dug", 1)
		assert.is_same(1, archtec_playerdata.get("Sam", "nodes_dug"))
	end)

	it("mod - increase by 1 (to 2)", function()
		archtec_playerdata.mod("Sam", "nodes_dug", 1)
		assert.is_same(2, archtec_playerdata.get("Sam", "nodes_dug"))
	end)

	it("test saving via globalstep", function()
		for _ = 1,1000 do
			mineunit:execute_globalstep(0.42)
		end
	end)
end)

mineunit:execute_on_leaveplayer(Sam)

describe("Test main functions (offline player)", function()
	it("get - check default", function()
		assert.is_same(2, archtec_playerdata.get("Sam", "nodes_dug"))
	end)

	it("set - set to 3", function()
		archtec_playerdata.set("Sam", "nodes_dug", 3)
		assert.is_same(3, archtec_playerdata.get("Sam", "nodes_dug"))
	end)

	it("mod - increase by 1 (to 4)", function()
		archtec_playerdata.mod("Sam", "nodes_dug", 1)
		assert.is_same(4, archtec_playerdata.get("Sam", "nodes_dug"))
	end)
end)