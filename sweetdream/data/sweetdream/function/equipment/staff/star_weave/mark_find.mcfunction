$execute store result score #weave_count zx.meta if entity @e[tag=zx.weave_mark,nbt={data:{owner:"$(owner)"}},distance=0..]
$execute unless entity @e[tag=zx.weave_mark,nbt={data:{owner:"$(owner)",t0:$(t0),t1:$(t1),t2:$(t2),t3:$(t3)}},distance=0..,limit=1] if score #weave_count zx.meta matches ..2 run summon minecraft:marker ~ ~ ~ {Tags:["zx.weave_mark","zx.weave_new"],data:{}}
execute if entity @e[tag=zx.weave_new,distance=0..,limit=1] run data modify entity @e[tag=zx.weave_new,distance=0..,limit=1] data set from storage zx:work weave
tag @e[tag=zx.weave_new,distance=0..] remove zx.weave_new
$execute as @e[tag=zx.weave_mark,nbt={data:{owner:"$(owner)",t0:$(t0),t1:$(t1),t2:$(t2),t3:$(t3)}},distance=0..,limit=1] run scoreboard players operation @s zx.weave_until = #now manacore.meta
$execute as @e[tag=zx.weave_mark,nbt={data:{owner:"$(owner)",t0:$(t0),t1:$(t1),t2:$(t2),t3:$(t3)}},distance=0..,limit=1] run scoreboard players add @s zx.weave_until 160
