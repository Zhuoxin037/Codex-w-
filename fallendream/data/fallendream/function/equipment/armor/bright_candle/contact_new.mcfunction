summon minecraft:marker ~ ~ ~ {Tags:["zx.bc_contact","zx.bc_pair_new"]}
$scoreboard players set @e[tag=zx.bc_pair_new,distance=..0.1,limit=1] zx.bc_parent $(cid)
$scoreboard players set @e[tag=zx.bc_pair_new,distance=..0.1,limit=1] zx.bc_target $(tid)
$scoreboard players set @e[tag=zx.bc_pair_new,distance=..0.1,limit=1] zx.bc_end $(end)
scoreboard players set @e[tag=zx.bc_pair_new,distance=..0.1,limit=1] zx.bc_near 0
scoreboard players set @e[tag=zx.bc_pair_new,distance=..0.1,limit=1] zx.bc_far 0
tag @e[tag=zx.bc_pair_new,distance=..0.1,limit=1] remove zx.bc_pair_new
