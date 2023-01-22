error("[archtec_playerdata] tried to execute 'doc.lua' file!!!")

archtec_playerdata.load(name) -- loads data from disk, player must be online
archtec_playerdata.unload(name) -- saves data and removes from cache, player must be online
archtec_playerdata.load_offline(name) -- returns data from disk (full table), player must be offline
archtec_playerdata.save(name) -- saves data of player
archtec_playerdata.save_all() -- saves data of all online players
archtec_playerdata.get(name, key) -- returns value of 'key' if nil then from struct table
archtec_playerdata.set(name, key, value) -- sets 'value' of given key (bool, number, string)
archtec_playerdata.mod(name, key, value) -- sets 'value' of given key + value (numbers only)
-- It is not possible to edit data of offline players! (todo?)
