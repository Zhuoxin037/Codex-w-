data modify storage zx:work rd_build set value {}
execute store result storage zx:work rd_build.i int 1 run scoreboard players get #rd_build_i zx.meta
function sweetdream:rogue/gen/build_pick with storage zx:work rd_build
scoreboard players add #rd_build_i zx.meta 1
execute if score #rd_build_i zx.meta matches 25.. run function sweetdream:rogue/gen/build_links
