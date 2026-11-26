summon minecraft:marker ~ ~ ~ {Tags:["zx.tf_prev","zx.tf_prev_new"]}
$scoreboard players set @e[tag=zx.tf_prev_new,distance=..0.1,limit=1] zx.sid $(sid)
scoreboard players operation @e[tag=zx.tf_prev_new,distance=..0.1,limit=1] zx.tf_born = #now manacore.meta
tag @e[tag=zx.tf_prev_new,distance=..0.1,limit=1] remove zx.tf_prev_new
