# Climate API
A powerful engine for weather presets and visual effects.

## Troubleshooting
Generally speaking, most mods should be compatible.

If you notice __odd movement speeds__ or jump heights of players, you should check for mods that also modify player physics. Use a compatibility mod like [player_monoids](https://github.com/minetest-mods/player_monoids) or [playerphysics](https://forum.minetest.net/viewtopic.php?t=22172) to get rid of this problem. This requires the conflicting mod to also support the chosen compatibility layer.

Mods that __modify the sky__ (including skybox, moon, sun, stars and clouds) are sadly not fully compatible because they conflict with Climate API's sky system. You should deactivate the sky features in either mod. You can do this here using the ``Override the skybox`` setting. If you're a mod maker then you can also optionally depend on climate_api and use ``climate_api.skybox.add_layer(playername, layer_name, options)`` to register your skybox change in a compatible way. Note that you need __at least Minetest v5.2.0__ for skybox changes to have any effect.

## Chat Commands
- ``/weather``: Display information on current weather effects. This command will show you current temperature and humidity, active weather presets and currently playing effects
- ``/weather_settings``: Display current mod configuration in the chat
- ``/weather_influences``: Display all different factors and how they affect you in this moment.
- ``/weather_status``: Display a list of all installed weather presets and whether they have been forced on, turned off, or are running normally (auto). If no weather presets are listed here then you need to install a weather mod like Regional Weather.
- ``/set_weather <weather> <on|off|auto>``: Set a weather preset to always be applied (on), disable it completely (off), or reset it to be applied automatically (auto). Turning presets on manually might result in partially missing effects (like no sound if you enable sandstorms but no storms). Use ``/weather_status`` for a full list of installed weather presets. The prefix is important.

## Configuration Options
You can find all mod configuration options in your Minetest launcher.
Go to ``Settings → All Settings → Mods → climate_api`` to change them.
Individual weather packs may provide additional configuration options in their respective mod configuration section.

### Performance
- ``Update speed of weather effects`` (default 1.0):
This value regulates how often weather presets are recalculated.
Higher values will result in smoother transitions between effects as well as faster response times to traveling players.
Lower values will significantly increase overall performance at the cost of rougher looking effects.
- ``Multiplicator for used particles`` (default 1.0):
This value regulates how many particles will be spawned.
A value of 1 will use the recommended amount of particles.
Lower values can possible increase performance.
- ``Dynamically modify nodes`` (default true):
If set to true, weather packs are allowed to register node update handlers.
These can be used to dynamically place snow layers, melt ice, or hydrate soil.

### Weather Effects
- ``Cause player damage`` (default true):
If set to true, dangerous weather presets will damage affected players over time.
- ``Show particle effects`` (default true):
If set to true, weather effects (like rain) are allowed to render particles.
Deactivating this feature will prevent some presets from being visible.
For performance considerations it is recommended to decrease the amount of particles instead.
- ``Override the skybox`` (default true):
If set to true, weather effects are allowed to modify a player's sky.
This includes skybox, sun, moon, and clouds (also used for fog effects).
Running this mod on Minetest 5.1.2 or earlier versions will automatically disable this feature.

### Preferences
- ``Play ambient sound loops`` (default true):
If set to true, weather effects are allowed to play sound loops.
Note that you can also adjust sound levels instead of deactivating this feature completely.
- ``Volume of sound effects`` (default 1.0):
This value regulates overall sound volume.
A value of 2 will double the volume whereas a value of 0.5 will reduce the volume by half.

## License
- Source Code: *GNU LGPL v3* by me
- Sun and moon textures: *CC BY-SA (3.0)* by Cap
