--[[ Format guide
archtec.faq.register("My nice title", { <- Title of the entry
    header = "Cool stuff", <- Name of the associated category
    pos = 1, <- Pos inside the category
    description = [[
My cool text" <- Content of the entry
]*] -- The * is not needed!
})
]]--

-- Chat
archtec.faq.register("Namecolor", {
    header = "Chat",
    pos = 1,
    description = [[
You can change your namecolor in the #main channel via '/namecolor <color'.
To see a list of supported colors, run '/namecolor' without params.
]]
})

archtec.faq.register("Private messages", {
    header = "Chat",
    pos = 2,
    description = [[
Run '/msg <name> <message>' to send <name> a message.
Run '/m <message>' to send the same person a message you sent your last message too.
]]
})

archtec.faq.register("Use and manage channels", {
    header = "Chat",
    pos = 3,
    description = [[
Join a channel:
'/c join <channel>' or
'/c j <channel>'

Leave a channel:
'/c leave <channel>' or
'/c l <channel>'

Invite someone in a channel:
'/c invite <channel> <name>' or
'/c i <channel> <name>'

List all channels:
'/c list' or
'/c li'

Find all channels where someone is:
'/c find <name>' or
'/c f <name>'

Kick someone from a channel. Can be used by channelowners and staff:
'/c kick <channel> <name>' or
'/c k <channel> <name>'

Get help:
'/c help <command>' or
'/c h <command>' (command is optional)
]]
})

archtec.faq.register("Chatbridge to Discord", {
    header = "Chat",
    pos = 4,
    description = [[
Since we use Matterbridge, we might add support for new platforms later.

The bridge supports the following commands and chat formats:
- Normal chat messages
- '/me' Shows ingame what you're doing (formatted like regular '/me')
- '!status' Shows the server status (like '/status' ingame)
- '!cmd' Remote command execution (staff only)
]]
})

-- Player interaction
archtec.faq.register("Ignoring", {
    header = "Player interaction",
    pos = 1,
    description = [[
You can ignore other players resp. other players can ignore you. This means you can no longer act together.
Not all functions on the server support ignoring, but most do :).

Ignore a player:
'/ignore add <name>' or
'/ignore ignore <name>'

Unignore a player:
'/ignore remove <name>' or
'/ignore unignore <name>'

List ignored players:
'/ignore list' or
'/ignore list <name>' (lists ignored players of <name>; staff only)
'/ignore' (without params)
]]
})

archtec.faq.register("Teleport requests", {
    header = "Player interaction",
    pos = 2,
    description = [[
Send a teleport request to another player:
'/tpr <name>'

Send a teleport to-me request to another player:
'/tp2me <name>'

Accept a teleport request:
'/ok'

All teleport requests have a 60 seconds timeout.
]]
})

archtec.faq.register("PvP", {
    header = "Player interaction",
    pos = 3,
    description = [[
Everyone on Archtec can decide if they want to fight aggainst other players or not.

To enable PvP, press in your inventory the button with the sword.
To disable PvP, press the button again.

PvP gets automatically disabled when you rejoin.
]]
})

archtec.faq.register("Votings", {
    header = "Player interaction",
    pos = 4,
    description = [[
Since new players often don't have etherium dust, each player can start 5 votings for free. The remaining free votings are shown in '/stats'.

Vote day:
- A vote to make day ingame
- Costs 3 etherium dust
- 60% needed majority

Vote night:
- A vote to make night ingame
- Costs 3 etherium dust
- 60% needed majority

Vote kick:
- A vote to kick players who misbehave
- Costs nothing
- 80% needed majority
- To prevent abuse, there must be at least 4 players online to start the vote
]]
})

archtec.faq.register("Stats", {
    header = "Player interaction",
    pos = 5,
    description = [[
We record precise stats about all players. Stats recording is activated since 2023-02-01. Previously only playtime and first join date were saved.

Run '/stats <name>' to get <name>'s stats.
]]
})

-- Spawn
archtec.faq.register("Unprotected areas", {
    header = "Spawn",
    pos = 1,
    description = [[
Yes, our spawn area is really big (>2000x2000 nodes).
There are different ways to find a nice place:

- Make a long trek out of the spawn area
- In the Teleporter house is a "Free area Travelnet", it can teleport you to different unprotected areas where you can build with others
]]
})

-- Player related
archtec.faq.register("Automatic priv granting", {
    header = "Player related",
    pos = 1,
    description = [[
We don't grant players special priv's, but the server will do that automatically.

Forceloading priv ('forceload'):
- You'll get the priv when you enter TA3 (just place a TA3 Oil Drillbox)

Using Lava buckets ('adv_buckets'):
- You must have 50 hours or more playtime
- Try to place a Lava bucket, you'll get the priv

More and bigger areas ('areas_high_limit'):
- You must have 30 hours or more playtime
- Run '/request_areas_high_limit' to get the priv

Using the chainsaw ('archtec_chainsaw'):
- You must have 24 hours or more playtime
- You must have 20k nodes dug
- You must have 10k nodes placed
- Your account must be older than 7 days
- Try to use a chainsaw, you'll get the priv
]]
})

archtec.faq.register("Homepoints", {
    header = "Player related",
    pos = 2,
    description = [[
There are two homepoints, you can set them independent of each other.

Home/Sethome:
- Run '/home' to teleport to the homepoint
- Run '/sethome' to set the homepoint to your current position

Inventory home:
- Use the homebutton with the green arrow in your inventory to teleport to the homepoint
- Use the homebutton with the red arrow to set the homepoint to your current postion
]]
})

-- Other
archtec.faq.register("Node placement limits", {
    header = "Other",
    pos = 1,
    description = [[
Drawers:
Minetest limits the static entitities per mapblock (16x16x16 nodes). Every drawer adds 1-4 extra entities, that's why we must limit the drawers per mapblock count.

Hoppers:
Every hopper adds much server load. You can place 10 hoppers in a 24 node radius. Note: The hoppers from the 'minecart' mod are much faster than the normal ones.

TA quarrys:
Many players build big cobble generator factories with quarrys, to limit the factory size a bit you can only place 3 quarrys in a 24 node radius.

Sign bots:
This small cute bots are sometimes big cruel lag bots :-P. You can place 7 sign bots in a 24 node radius.
]]
})

archtec.faq.register("Towercrane", {
    header = "Other",
    pos = 2,
    description = [[
Towercranes can be hard to understand, but there pretty simple.

1. Place the crane and rightclick it
2. Enter the height and width comma seperated. E.g. '20,30' will build a 20 nodes high and 30 nodes width crane.
3. To start flying, rightlick the big red button on the crane and press "K" on your keyboard.

To stop flying, press the big green button on the crane.
]]
})