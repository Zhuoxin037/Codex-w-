# 宏 {u0,u1,u2,u3} = 施法者 UUID 四 int, 存进领域 marker 供标签转移反查主人。
# @s = 施法者, 位置 = 施法者位置(execute at @s)。
$summon minecraft:marker ~ ~ ~ {Tags:["zx.lw_field","zx.lw_new"],data:{zx:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}
execute as @e[tag=zx.lw_new,distance=..1,limit=1] run scoreboard players operation @s zx.lw_end = #now manacore.meta
execute as @e[tag=zx.lw_new,distance=..1,limit=1] run scoreboard players add @s zx.lw_end 320
tag @e[tag=zx.lw_new,distance=..1] remove zx.lw_new
particle minecraft:enchant ~ ~0.3 ~ 3 0.2 3 0.03 30 normal
