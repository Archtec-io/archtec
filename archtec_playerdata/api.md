`archtec_playerdata` API Reference
==================================

* `archtec_playerdata.register_key(key_name, key_type, default_value[, temp])`: returns `nil` or stopps
  the server on startup.
    * Registers a database key
    * Must be called during mod load time
    * Key must not start with `system_`
    * key_name: `string`, key_type: `string`, default_value: `*`, temp: `boolean`

* `archtec_playerdata.register_upgrade(key_name, identifier, run_always, func)`: returns `nil` or stopps
  the server on startup.
    * Registers a upgrade for all players
    * Must be called during mod load time
    * The identifier gets stored after a single run upgrade to not run it again
      Format identifier as `modname:anything` to prevent ID collisions
    * key_name: `string`, identifier: `string`, run_always: `boolean`, func: `function`

* `archtec_playerdata.register_removal(key_name)`: returns `nil` or stopps
  the server on startup.
    * Removes a key completely from the database on startup
    * **WARNING**: Deletes data, use with caution!
    * key_name: `string`

* `archtec_playerdata.get_default(key_name)`: returns `default_value` or `nil` if
  key does not exist.
    * Get the default value of a key
    * key_name: `string`

* `archtec_playerdata.get(name, key_name)`: returns `value` or `nil`
    * Get value of key for a player (or default value if unset)
    * Can't be used in `on_shutdown` callbacks
    * Return of `nil` is caused by unknown key, corrupted data (unknown player works)
    * name: `string`, key_name: `string`

* `archtec_playerdata.get_all(name)`: returns `table` with data or `nil`
    * Get all key=value pairs of a player
    * Can't be used in `on_shutdown` callbacks
    * Return of `nil` is caused by corrupted data, unknown player
    * name: `string`

* `archtec_playerdata.get_db()`: returns `table` or `nil`
    * Get key=value pairs of all players
    * Can be used in `on_shutdown` callbacks
    * Does not return never set values, you must query the defaults yourself

* `archtec_playerdata.set(name, key_name, value)`: returns `true` (success) or `false` (failure)
    * Set key of player to value
    * Can't be used in `on_shutdown` callbacks
    * Return of `false` is caused by corrupted data, unknown player, wrong data type of `value`
    * name: `string`, key_name: `string`, value: `*`

* `archtec_playerdata.mod(name, key_name, value)`: returns `true` (success) or `false` (failure)
    * Modify key of player by value (number)
    * Can't be used in `on_shutdown` callbacks
    * Return of `false` is caused by corrupted data, unknown player, type of `value` ~= `number`
    * name: `string`, key_name: `string`, value: `number`

* `archtec_playerdata.backup_create()`: returns `true` (success) or `false` (failure)
    * Creates a backup file in `$WORLDPATH/archtec_playerdata/`
    * Filename looks like this `archtec_playerdata_2024-01-01_20:00:00.txt`

* `archtec_playerdata.backup_restore(filename)`: returns `true` (success) or `false` (failure)
    * Overwrites database from backup file
    * File must be in `$WORLDPATH/archtec_playerdata/`
    * Must be called on mod load time before startup procedure
    * **WARNING**: Deletes **all** data, use with caution!
    * filename: `string`