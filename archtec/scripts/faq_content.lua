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
Use '/m <message>' to message the same person your last message was sent to.
]]
})

archtec.faq.register("Use and manage channels", {
    header = "Chat",
    pos = 3,
    description = [[
To send a message to a channel prepend the message with '#' followed by the channel name. (e.g. '#staff hiho')

Required arguments/parameters are indicated with angle braces <> while optional ones are have curly braces {}.

Join/Create a channel: (Add 'yes' to your command to make new the created channel public)
'/c join <channel> {yes}' or
'/c j <channel> {yes}'

Leave a channel:
'/c leave <channel>' or
'/c l <channel>'

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

archtec.faq.register("Chatbridge to Discord", {
    header = "Chat",
    pos = 4,
    description = [[
The Discord chart bridge uses Matterbridge facilitating additional platform integrations in the future.

The following commands and chat formats are supported:
- Regular chat messages
- '/me' Used in conjunction with a verb do indicate you as a player performing an action as described by a 3rd person, e.g. /me talks -> Player talks
- '!status' Shows the server status
- '!cmd' Remote command execution (staff only)
]]
})

-- Player blocking
archtec.faq.register("Interaction", {
    header = "Player interaction",
    pos = 1,
    description = [[
Allows you to block other players from interacting and communicating with you.
Currently ignore isn't supported by all features/functions but most are. :).

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
Each player on Archtec can opt in or out of PvP mode, opting into PvP mode allows other players to harm/fight you and allows you to harm/fight other players that have opted into PvP mode.

- To enable PvP, toggle the sword button in your inventory screen.
- To disable PvP, toggle the button again.

PvP mode gets reset on login and has to be re-enabled for each login session.
]]
})

archtec.faq.register("Voting", {
    header = "Player interaction",
    pos = 4,
    description = [[
There are three kinds of votes a player on Archtec can initiate:

Each player starts with 5 free votes since it might take new player a while to get etherium dust. To check how many free votes you have remaining use the '/stats' command.

Vote to make it day:
- Turns in-game night into day
- Costs 3 etherium dust
- Requires 60% of votes to be YES to succeed

Vote to make it night:
- Turns in-game day into night
- Costs 3 etherium dust
- Requires 60% of votes to be YES to succeed

Vote to kick a player:
- Kicks a mis-behaving player off the server
- Costs nothing
- Requires 80% of votes to be YES to succeed
- To prevent abuse there must be at least 4 players online to initate the vote
]]
})

archtec.faq.register("Stats", {
    header = "Player interaction",
    pos = 5,
    description = [[
Archtec records certain statistics on all players. To see statistics for a player you can use the stats command.

To show a players statistics use:
- '/stats <name>'
]]
})

archtec.faq.register("Thank you", {
    header = "Player interaction",
    pos = 6,
    description = [[
The are many helpful players on Archtec, if someone has been helpful and you want to thank them and call them out for their assistance use the '/thankyou' command. To see how many 'thankyou's a player has received use the '/stats' command.

    :-)

To thank a player:
'/thankyou <name>'
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

archtec.faq.register("Areas without protection", {
    header = "Spawn",
    pos = 2,
    description = [[

The Archtec spawn area is very large (>2000x2000 nodes) and most players want to find a place where they can mine, build or interact with the environtment.

Players can choose one of several ways to get out of the protected spawn area and find a nice place to make their own.

- There is a white "Teleporter" house adjacent to spawn platform, inside you will find several teleporters that will instantly transport you to mining and building sites where you can start your build/mine/journey. If at any time you want to return to spawn just type '/spawn'
- Walking out of spawn can be a rewarding experience since you can see all the fantastic bulids and structures other players have created. Note that it will take a while and be prepared to walk a bit further than the edge of spawn to find a nice place. You might want to consider using the '/sethome' command to save your progress so if you have an accident you can return to where your bones and pick up your stuff
- If you want to build far from others you might want to check out the online Archtec Map http://map.archtec.freemyip.com:8585
- Some players have created their own personal travel nets that go to the very edges of the universe, ask around if your curios and want to discover just how big our server is.
]]
})

-- Player related
archtec.faq.register("Privileges", {
    header = "Player related",
    pos = 1,
    description = [[
Some actions and block interactions require special privileges due to having the potential of being very destructive or negatively impacting other players or server performance.

Admins will not grant individual player privileges but some privileges are automatically granted as players reach certain milestones or gain experience.

Forceload ('forceload'):
- The ability to place forceload blocks
- Granted when a player reaches Techage Level 3 (places first TA3 Oil Drillbox) 
- Forceload blocks cause the mapblock (16x16x16) area they are placed in to be continously loaded while a player is logged in regardless of where they are.

Lava buckets ('adv_buckets'):
- Requires 50 hours of playtime (player being logged in and playing on the server)
- Granted when you place/pour your first lava bucket which you'll be able to do after reaching 50 hours of play time.

Bigger and more protected areas ('areas_high_limit'):
- Requires 30 hours of playtime (player being logged in and playing on the server)
- Execute the '/request_areas_high_limit' command to be granted the privilege

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

Archtec supports two separate systems by which a player can save their home location and instantly teleport to that location. The first system uses the command console with '/sethome' and '/home' while the other system uses the red/green arrow home buttons in the player inventory GUI.

The two home positions are completly independent which allows a player to have two home positions set.

System 1 - Home/Sethome:
- Execute '/home' to teleport to your home position
- Execute '/sethome' to set your home position to your current position

System 2 - Inventory home:
- Use the green arrow home button in the inventory window to teleport to the home position
- Use the red arrow home button in the inventory window to set your home to your current postion
]]
})

archtec.faq.register("Settings", {
    header = "Player related",
    pos = 3,
    description = [[
- Main settings: Press the cog/sprocket button in your inventory window
- Namecolor: See FAQ/Chat/Namecolor
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
Each drawer adds 1-4 entities resulting in the number of drawers per mapblock being restricted.

Hoppers:
Hoppers add a significant amount of server load and for performance reasons each player is restricted to 10 hoppers in any given 24 node radius.
Where possible it's recommended to use the hoppers from the 'minecart' mod rather than the default hoppers.

Techage (TA) quarries:
To prevent oversize factories there is a hard limit of 3 on the number of Techage (TA)
Quarries each player is allowed to place within a 24 node radius.

Sign bots:
These cute little bots while being very useful can also cause a significant amount of lag and performance issues.
To prevent this from impacting other players each player is limted to placing 7 signs bots within a 24 node radius.
]]
})

archtec.faq.register("Tower cranes", {
    header = "Other",
    pos = 2,
    description = [[
Tower cranes allow a player to freely move within the boundaries set during the crane construction (similar to how players can move/fly in creative mode).

1. Place the crane and right-click it to enter the crane menu.
2. Enter the desired height/length comma separated. e.g. '20,30', this will build a crane 20 nodes high and 30 nodes long.
3. To start flying right-click the red button on the crane and press "K" on your keyboard.

To stop flying press the green button on the crane.
]]
})

archtec.faq.register("Lava solidification", {
    header = "Other",
    pos = 3,
    description = [[
Lava can turn into several other node types when it solidifies depending on whether it's still or flowing and which cooling block it comes into contact with.

Cooling blocks can be:
- Water
- Ice
- Thin Ice
- Dry Ice

Archtec behaviour:
- All still lava ('lava_source') turns into obsidian regardless of which cooling block it comes into contact with.
- Flowing lava that comes into contact with water, ice or thin ice turns into basalt stone.
- Flowing lava that comes into contact with dry ice turns into cobblestone

This differs significantly from the default minetest behaviour where all flowing lava turns into cobblestone when it comes into contact with water or ice.

For players building cobblestone generators you will have to use dry ice instead of water or ice for your generator to yield regular cobblestone.

- Dry ice is produced from water and diamond powder with a Techage (TA4) chemical reactor
- Diamond powder drops in Techage (TA) gravel rinsers with probability 1/300

For more information see the Techage manual or in-game guide.
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

Titanium tools are more durable than diamond or mithril tools but they tend to be slower.
]]
})

archtec.faq.register("Useful chat commands", {
    header = "Other",
    pos = 5,
    description = [[
- '/discord' will send you a link to our Discord server
- '/faq' shows this Frequenty Asked Questions section
- '/news' show the news from join again (staff only)
- '/report' report an bug/issue/feature-request to the server staff (Creates a GitHub issue, see discord for links to issues)
- '/area_flak <id>' close the airspace above your area for hanggliders (prevent other players from flying above your protected area, see '/list_areas' to get ID)

Techage:
- '/my_expoints' show your TA 5 experience points
- '/ta_color' show a color pallete for controller
- '/ta_limit' show your TA command limit
]]
})
