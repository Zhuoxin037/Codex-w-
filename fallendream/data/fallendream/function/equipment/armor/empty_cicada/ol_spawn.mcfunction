$summon minecraft:marker $(x) $(y) $(z) {Tags:["zx.s2_cicada","zx.s2_cicada_extra","zx.s2_extra_new"],data:{owner:"$(owner)",ol:1b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}
scoreboard players operation @e[tag=zx.s2_extra_new,distance=0..,limit=1] zx.s2_end = #now manacore.meta
scoreboard players add @e[tag=zx.s2_extra_new,distance=0..,limit=1] zx.s2_end 600
tag @e[tag=zx.s2_extra_new,distance=0..] remove zx.s2_extra_new
