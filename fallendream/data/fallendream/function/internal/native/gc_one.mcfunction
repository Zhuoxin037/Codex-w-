scoreboard players set #native_exists zx.meta 0
$execute in minecraft:overworld if entity $(uuid) run scoreboard players set #native_exists zx.meta 1
$execute in minecraft:the_nether if entity $(uuid) run scoreboard players set #native_exists zx.meta 1
$execute in minecraft:the_end if entity $(uuid) run scoreboard players set #native_exists zx.meta 1
execute if score #native_exists zx.meta matches 1 run data modify storage zx:work native_gc_next append from storage zx:work native_gc_queue[0]

$execute in minecraft:overworld as $(uuid) run scoreboard players operation @s zx.native_gen = #native_gen zx.meta

$execute in minecraft:the_nether as $(uuid) run scoreboard players operation @s zx.native_gen = #native_gen zx.meta

$execute in minecraft:the_end as $(uuid) run scoreboard players operation @s zx.native_gen = #native_gen zx.meta
