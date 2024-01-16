--[[ Format guide
archtec.faq.register("My nice title", { <- Title of the entry
	header = "Cool stuff", <- Name of the associated category
	pos = 1, <- Position inside the section
	description = [[
My cool text" <- Description of the section content
]*] -- The * is not needed
})
]]--

-- Chat
archtec.faq.register("Namecolor", {
	header = "Chat",
	pos = 1,
	description = [[
You can change your namecolor in the #main channel via '/namecolor <color>'.
To see a list of supported colors, use '/namecolor' without params.
]]
})

archtec.faq.register("Private messages", {
	header = "Chat",
	pos = 2,
	description = [[
Use '/msg <name> <message>' to message another player.
Use '/m <message>' to send a message to the person you sent your last message to.
]]
})

archtec.faq.register("Channels", {
	header = "Chat",
	pos = 3,
	description = [[
To send a message to a channel, prepend the message with '#' followed by the channel name. (e.g. '#staff hiho')

Required arguments/parameters are indicated with angle braces <> while optional ones have curly braces {}.

Join/Create a channel: (Add 'public' to your command to make the newly created channel public. Add 'default' to your command to make the newly created channel your default channel)
'/c join <channel> {public} {default}' or
'/c j <channel> {public} {default}'

Leave a channel:
'/c leave <channel>' or
'/c l <channel>'

Make a channel your default channel:
'/c default <channel>' or
'/c def <channel>'

Invite someone to a channel:
'/c invite <channel> <name>' or
'/c i <channel> <name>'

List all channels:
'/c list' or
'/c li'

List all channels a player is currently in:
'/c find <name>' or
'/c f <name>'

Kick a player from a channel. Can only be used by channel owners and staff:
'/c kick <channel> <name>' or
'/c k <channel> <name>'

Show help:
'/c help {command}' or
'/c h {command}'
]]
})

archtec.faq.register("Chatbridge to Discord, Matrix and IRC", {
	header = "Chat",
	pos = 4,
	description = [[
The chat bridge uses Matterbridge, facilitating additional platform integrations in the future.

Links to the platforms are in '/news'.

The following commands and chat formats are supported:
- Regular chat messages
- '/me' Used in conjunction with a verb to indicate you as a player acting as described by a 3rd person, e.g., '/me talks' -> Player talks
- '!status' Shows the server status
- '!cmd' Remote command execution (staff only)
]]
})

-- Player interaction
archtec.faq.register("Interaction", {
	header = "Player interaction",
	pos = 1,
	description = [[
'/ignore' allows you to block other players from interacting and communicating with you.
Ignore is currently not supported by all functions, but by most :).

Block/Ignore a player:
'/ignore add <name>' or
'/ignore ignore <name>'

Unblock/Un-ignore player:
'/ignore remove <name>' or
'/ignore unignore <name>'

List blocked/ignored players:
'/ignore list' or
'/ignore list {name}' (lists ignored players of <name>; staff only)
'/ignore'
]]
})

archtec.faq.register("Teleport requests", {
	header = "Player interaction",
	pos = 2,
	description = [[
Request to teleport to another players position:
'/tpr <name>'

Offer another player to teleport to your position:
'/tp2me <name>'

Accept a teleport request:
'/ok'

All teleport requests time out after 60 seconds.
]]
})

archtec.faq.register("PvP", {
	header = "Player interaction",
	pos = 3,
	description = [[
Each player on Archtec can opt in or out of PvP mode. If you enable PvP mode, other players can hurt/fight against you, and you can fight other players who have chosen PvP mode.

- To enable PvP, toggle the sword button in your inventory screen.
- To disable PvP, toggle the button again.

PvP mode gets disabled when logging off. You have to re-enable it after logging back in.
]]
})

archtec.faq.register("Voting", {
	header = "Player interaction",
	pos = 4,
	description = [[
There are three kinds of votes a player on Archtec can initiate:

Each player starts with 5 free votes since it might take new players a while to get Etherium Dust. To check how many free votes you have remaining, use the '/stats' command.

Vote to skip the night (switches to daytime if the voting succeeds):
- Turns in-game night into day
- Costs 3 etherium dust
- Requires 60% of votes to be YES to succeed

Vote to skip the day (switches to nighttime if the voting succeeds):
- Turns in-game day into night
- Costs 3 etherium dust
- Requires 60% of votes to be YES to succeed

Vote to kick a player:
- Kicks a misbehaving player off the server
- Costs nothing
- Requires 80% of votes to be YES to succeed
- To prevent abuse, there must be at least 4 players online to initiate the vote
]]
})

archtec.faq.register("Stats & Ranking", {
	header = "Player interaction",
	pos = 5,
	description = [[
Archtec records some statistics on all players. To see the stats of a player, you can use the '/stats' command. Stats recording was enabled at 2023-02-01. Previously, only playtime and the first join date were saved.

To show a player's statistics use:
- '/stats <name>'

To show a ranking of the players with the most XP*:
- '/rank'

* XP points are calculated from various other values (e.g., dug nodes) and ranked.
]]
})

archtec.faq.register("Thank you", {
	header = "Player interaction",
	pos = 6,
	description = [[
There are many helpful players on Archtec. If someone has been helpful and you want to thank them and call them out for their assistance, use the '/thankyou' command. To see how many thankyou's a player has received, use the '/stats' command. :-)

To thank a player:
'/thankyou <name>'
]]
})

archtec.faq.register("Areas", {
	header = "Player interaction",
	pos = 7,
	description = [[
Based on: https://archtec.niklp.net/areas/

Areas information

1. Get information about the `areas` mod configuration
- `/areas_info` (no params accepted)


Protect an area

1. Specify the corner positions of the area you would like to protect
- `/area_pos1` and `/area_pos1` sets the two corner positions to your current positions
- `/area_pos set` punch the two corner positions to set them

2. Protect the selected area
- `/protect <Areaname>`

The area name is used only for informational purposes and has no functional importance.


Add an owner to your area

1. Select the area to which you want to add an owner
- `/select_area <ID>` `ID` is the number you can see at the bottom left in square brackets (`[]`)

2. Create a new area with new owner
- `/add_owner <ID> <Name> <Areaname>` Use for `ID` the same as in 1. `Name` is the player you want to give owner rights, choose for `Areaname` a name you want


Open an area temporary

1. Open a specified area for all players
- `/area_open <ID>` `ID` is the number you can see at the bottom left in square brackets (`[]`)


Change the owner of an area

1. Change the owner of a specified area
- `/change_owner <ID> <Name>` Gives `Name` control over the specified area


List areas

1. List all areas you own
- `/list_areas` (no params accepted)


Change the size of an area (staff only)

1. Set new positions
- See `Protect an area -> 1`.

2. Change the size
- `/move_area <ID>` `ID` is the number you can see at the bottom left in square brackets (`[]`)


Remove an area

1. Remove an area
- `/remove_area <ID>` `ID` is the number you can see at the bottom left in square brackets (`[]`)

2. Removes an area and all sub-areas of it
- `/recursive_remove_areas <ID>` `ID` is the number you can see at the bottom left in square brackets (`[]`)


Rename an area

1. Rename a specified area
- `/rename_area <ID> <Areaname>` `ID` is the number you can see at the bottom left in square brackets (`[]`), choose for `Areaname` a name you want
]]
})

-- Spawn
archtec.faq.register("Teleport to spawn", {
	header = "Spawn",
	pos = 1,
	description = [[
To teleport back to Spawn:
- '/spawn' or '/s'

To teleport back to Old Spawn:
- '/spawn_old' or '/s_o'
]]
})

archtec.faq.register("Find areas without protection", {
	header = "Spawn",
	pos = 2,
	description = [[
The Archtec spawn area is very large (>2000x2000 nodes), and most players want to find a place where they can mine, build, or interact with the environment.

Players can choose one of several ways to get out of the protected spawn area and find a nice place to make their own.

- There is a white "Teleporter" house adjacent to the spawn platform, where you will find several teleporters that will instantly transport you to mining and building sites where you can start your build/mine/journey. If at any time you want to return to spawn, just type '/spawn'
- Walking out of spawn can be a rewarding experience since you can see all the fantastic builds and structures other players have created. Note that it will take a while, and should be prepared to walk a bit further than the edge of spawn to find a nice place. You might want to consider using the '/sethome' command to save your progress so if you have an accident, you can return to where your bones are and pick up your stuff
- If you want to build far from others, you might want to check out the online Archtec Map https://archmap.niklp.net.
- Some players have created their own personal Travelnet Networks, that go to the very edges of the universe. Ask around if you are curious and want to discover, how big our server is.
]]
})

-- Player related
archtec.faq.register("Privileges", {
	header = "Player related",
	pos = 1,
	description = [[
Some actions and block interactions require special privileges due to having the potential of being very destructive or negatively impacting other players or server performance.

Admins will not grant individual player privileges, but some privileges are automatically granted as players reach certain milestones or gain experience.

Forceload ('forceload'):
- The ability to place forceload blocks
- Granted when a player reaches Techage Level 3 (places first TA3 Oil Drillbox)
- Forceload blocks cause the mapblock (16x16x16 nodes) area they are placed in to be continuously loaded while a player is logged in regardless of where they are.

Lava buckets ('adv_buckets'):
- Requires 50 hours of playtime (player being logged in and playing on the server)
- Granted when you place/pour your first lava bucket which you'll be able to do after reaching 50 hours of playtime.

Bigger and more protected areas ('areas_high_limit'):
- Requires 30 hours of playtime (player being logged in and playing on the server)
- When the condition is met, you'll be granted the privilege when needed automatically.

Chainsaw ('archtec_chainsaw'):
- Requires 24 hours of playtime (player being logged in and playing on the server)
- Requires a player to have mined/dug/chopped 20000 nodes (see '/stats' command)
- Requires a player to have placed 10000 nodes (see '/stats' command)
- The player account must be at least 7 days old
- When all those conditions are met you'll be granted the privilege by using the chainsaw for the first time.
]]
})

archtec.faq.register("Teleport Home", {
	header = "Player related",
	pos = 2,
	description = [[
Archtec supports two separate systems by which players can save their home location and instantly teleport to that location. The first system uses the command console with '/sethome' and '/home'. The second system uses the red/green arrow home buttons in the player inventory GUI.

The two home positions are completely independent. That allows a player to have two home positions set.

System 1 - Home/Sethome:
- Execute '/home' to teleport to your home position
- Execute '/sethome' to set your home position to your current position

System 2 - Inventory home:
- Use the green arrow home button in the inventory window to teleport to the home position
- Use the red arrow home button in the inventory window to set your home to your current position
]]
})

archtec.faq.register("Settings", {
	header = "Player related",
	pos = 3,
	description = [[
- Main settings: Press the cog/sprocket button in your inventory window
- Namecolor: See FAQ->Chat->Namecolor
- Skin: Press the "face" button in your inventory
- Hotbar size: Execute '/hotbar <size>' to change the size of your hotbar
]]
})

-- Other
archtec.faq.register("Node placement limits", {
	header = "Other",
	pos = 1,
	description = [[
Drawers:
Minetest has a fixed limit on the number of static entities supported per mapblock (16x16x16 nodes).
Each drawer adds 1-4 entities, resulting in the number of drawers per mapblock having to be restricted.
You can't place new drawers when the mapblock contains more than 70 entities.

Hoppers:
Hoppers add a significant amount of server load, and for performance reasons, each player is restricted to 10 hoppers in any given 24-node radius.
Where possible it's recommended to use the hoppers from the 'minecart' mod rather than the default hoppers.

Techage (TA) quarries:
To prevent oversize factories, there is a hard limit of 3 on the number of Techage (TA)
Quarries each player is allowed to place within a 24-node radius.

Sign Bots:
While these cute little bots are very useful, they can also cause significant lag and performance issues.
To prevent this from impacting other players, each player is limited to placing 7 Signs Bots within a 24-node radius.
]]
})

archtec.faq.register("Tower cranes", {
	header = "Other",
	pos = 2,
	description = [[
Tower cranes allow a player to freely move within the boundaries set during the crane construction (similar to how players can move/fly in creative mode).

1. Place the crane and right-click it to enter the crane menu.
2. Enter the desired height/length comma separated. e.g., '20,30', this will build a crane 20 nodes high and 30 nodes long.
3. To start flying, right-click the red button on the crane and press "K" on your keyboard.

To stop flying, press the green button on the crane.
]]
})

archtec.faq.register("Lava solidification", {
	header = "Other",
	pos = 3,
	description = [[
Lava can turn into several other node types when it solidifies, depending on whether it's still or flowing and which cooling block it comes into contact with.

Cooling blocks can be:
- Water
- Ice
- Thin Ice
- Dry Ice

Archtec behavior:
- All still lava ('lava_source') turns into obsidian regardless of which cooling block it comes into contact with.
- Flowing lava that comes into contact with water, ice, or thin ice turns into basalt stone.
- Flowing lava that comes into contact with dry ice turns into cobblestone

This differs significantly from the default minetest behavior, where all flowing lava turns into cobblestone when it comes into contact with water or ice.

For players building cobblestone generators, you must use dry ice instead of water or ice for your generator to yield regular cobblestone.

- Dry ice is produced from water and diamond powder with a Techage (TA4) chemical reactor
- Diamond powder drops in Techage (TA) gravel rinsers with a probability of 1/300

For more information, see the Techage manual or in-game guide.
]]
})

archtec.faq.register("Ores and Tools", {
	header = "Other",
	pos = 4,
	description = [[
Special ores:
- Bauxite can be found at depths between -50 and -500
- Baborium can be found at depths between -250 and -340
- Titanium can be found at depths between -1500 and -30000

- Titanium doesn't drop in Techage (TA) gravel sieves

Titanium tools are more durable than diamond or mithril tools, but Titanium tools tend to be slower.
]]
})

archtec.faq.register("Useful chat commands", {
	header = "Other",
	pos = 5,
	description = [[
General:
- '/faq' shows this Frequently Asked Questions section
- '/news' shows the news from join again (staff only)
- '/report <msg>' report a bug/issue/feature request to the server staff (Creates a GitHub issue and a Discord notification)
- '/area_flak <id>' close the airspace above your area for hanggliders (prevent other players from flying above your protected area, see '/list_areas' to get ID)

Techage:
- '/my_expoints' show your TA 5 experience points
- '/ta_color' shows a color palette for the controller
- '/ta_limit' show your TA command limit
]]
})

archtec.faq.register("TNT and explosions", {
	header = "Other",
	pos = 6,
	description = [[
There is no way for players to use TNT on Archtec. If you want to clear large areas, you should use techage quarries instead.

The following mobs can cause explosions:
- Dugeon master (DM), when it hits a node, radius 1
- Tree monster, when it spawns near Acacia Bush Leaves (default:acacia_bush_leaves), radius 6
]]
})

archtec.faq.register("Biofuel", {
	header = "Other",
	pos = 7,
	description = [[
Biofuel is produced in the Biofuel Refinery.

Biofuel has multiple use cases:
- As fuel for the chainsaw
- As fuel for the TA3 Tiny Power Generator

- As a craft ingredient, search in your inventory after "group:biofuel"
]]
})