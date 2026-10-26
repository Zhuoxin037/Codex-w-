summon minecraft:marker ~ ~ ~ {Tags:["sd.hk.leap_mark","sd.hk.jump_start","sd.hk.new_mark"]}
$scoreboard players set @e[tag=sd.hk.new_mark,distance=..0.01,limit=1] sdh.id $(id)
tag @e[tag=sd.hk.new_mark,distance=..0.01] remove sd.hk.new_mark
summon minecraft:marker ~ ~ ~ {Tags:["sd.hk.leap_mark","sd.hk.jump_end","sd.hk.new_mark"]}
$scoreboard players set @e[tag=sd.hk.new_mark,distance=..0.01,limit=1] sdh.id $(id)
execute as @a[tag=sd.hk.leap_player,limit=1] run function sweetdream:boss/husk/leap/cache_player
$data modify entity @e[tag=sd.hk.jump_end,scores={sdh.id=$(id)},limit=1,distance=0..] data set from storage sweetdream:husk leap_player
execute if entity @a[tag=sd.hk.leap_player] at @a[tag=sd.hk.leap_player,limit=1] run tp @e[tag=sd.hk.new_mark,distance=0..,limit=1] ~ ~ ~
execute unless entity @a[tag=sd.hk.leap_player] at @e[tag=sd.hk.target,distance=0..,limit=1] run tp @e[tag=sd.hk.new_mark,distance=0..,limit=1] ~ ~ ~
tag @e[tag=sd.hk.new_mark,distance=0..] remove sd.hk.new_mark
