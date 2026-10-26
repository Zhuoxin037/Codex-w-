$summon minecraft:marker ~ ~ ~ {Tags:["zx.et_wave","zx.et_set","zx.et_new"],data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}
scoreboard players operation @e[tag=zx.et_new,distance=..0.1,limit=1] zx.et_life = #et_life zx.meta
scoreboard players set @e[tag=zx.et_new,distance=..0.1,limit=1] zx.et_fx 0
execute as @e[tag=zx.et_new,distance=..0.1,limit=1] at @s run function sweetdream:equipment/visual/water/create {model:"sweetdream:ebb_wave",sx:5.0,sy:5.0,sz:5.0,life_obj:"zx.et_life",kind:"wave"}
tag @e[tag=zx.et_new,distance=..0.1,limit=1] remove zx.et_new
