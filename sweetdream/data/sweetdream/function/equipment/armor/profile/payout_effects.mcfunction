# 剖面的三击兑现效果（回魔50、低血目标噬心、回血10%）；套装的全部效果由all_effects补齐。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/profile/gain
execute as @a[tag=zx.ub,limit=1] at @s as @e[type=#sweetdream:living,type=!minecraft:player,distance=..5] run function sweetdream:equipment/armor/profile/mark_lo
execute as @a[tag=zx.ub,limit=1] run function sweetdream:equipment/armor/profile/heal
execute at @s run particle minecraft:dust{color:[0.35,0.85,0.80],scale:1.3} ~ ~1 ~ 0.4 0.5 0.4 0.02 18 normal
execute at @s run playsound minecraft:block.amethyst_cluster.place player @a ~ ~ ~ 0.6 1.5
