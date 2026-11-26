data modify storage zx:work rg_view set value {cell:10}
data modify storage zx:work rg_view.flags set from storage zx:rogue floor.flags
data modify storage zx:work rg_view.types set from storage zx:rogue floor.types
execute store result storage zx:work rg_view.cell int 1 run scoreboard players get @s zx.rg_room
function fallendream:rogue/map/refresh_go with storage zx:work rg_view
scoreboard players operation @s zx.rg_seen = @s zx.rg_room
scoreboard players operation @s zx.rg_rev = #rd_rev zx.meta
