# 天火 法球命中回调: @s=法球, 位置=命中点, data 内含射手 u0..u3。
# 反查射手, 判断此刻是否在"强化窗口(zx.sf_orb>=1 且 zx.sf_end>#now)"里:
#   强化 -> 消耗一次次数, 登记 20 刻/3 格火球; 普通 -> 40 刻/2 格火球。
# 参数冻结进 zx:work sf, 再交给新生成的 marker 逐只读取(同刻多球串行, 不串味)。
data modify storage zx:work sf set value {u0:0,u1:0,u2:0,u3:0,emp:0}
data modify storage zx:work sf.u0 set from entity @s data.u0
data modify storage zx:work sf.u1 set from entity @s data.u1
data modify storage zx:work sf.u2 set from entity @s data.u2
data modify storage zx:work sf.u3 set from entity @s data.u3
function fallendream:lib/find_by with storage zx:work sf
scoreboard players set #sf_emp zx.meta 0
execute as @a[tag=zx.mc_by,limit=1] if score @s zx.sf_orb matches 1.. if score @s zx.sf_end > #now manacore.meta run scoreboard players set #sf_emp zx.meta 1
execute if score #sf_emp zx.meta matches 1 as @a[tag=zx.mc_by,limit=1] run scoreboard players remove @s zx.sf_orb 1
execute if score #sf_emp zx.meta matches 1 run data modify storage zx:work sf.emp set value 1
tag @a remove zx.mc_by
summon minecraft:marker ~ ~ ~ {Tags:["zx.sf_pend","zx.sf_new"]}
execute as @e[tag=zx.sf_new,distance=..1] at @s run function fallendream:equipment/staff/skyfire/sf_init
tag @e[tag=zx.sf_new,distance=..1] remove zx.sf_new
