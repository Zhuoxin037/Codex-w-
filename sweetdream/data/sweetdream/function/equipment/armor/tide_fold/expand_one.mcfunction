$summon minecraft:marker ~ ~ ~ {Tags:["zx.et_wave","zx.et_set","zx.et_new"],data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}
scoreboard players operation @e[tag=zx.et_new,distance=..0.1,limit=1] zx.et_life = #et_life zx.meta
scoreboard players set @e[tag=zx.et_new,distance=..0.1,limit=1] zx.et_fx 0
tag @e[tag=zx.et_new,distance=..0.1,limit=1] remove zx.et_new
