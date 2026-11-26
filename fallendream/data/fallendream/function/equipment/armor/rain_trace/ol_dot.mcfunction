# ============================================================
# fallendream:equipment/armor/rain_trace/ol_dot —— 超限·每秒一次持续伤害（执行者 = 水迹点）
# ------------------------------------------------------------
# 【谁调用它】① ol_link（附上那一刻立刻来一发）
#             ② dot_tick ③.7（每秒一拍，见 zx.rt_beat）
# 【目标】标语 zx.rt_lnk 且 zx.rt_pid = 本摊编号的生物 —— **不论它现在在不在水迹上**
# 【原文】"…之后不论其有没有在水迹上都会每秒使其受到一次相当于释放者基础攻击力 ×2
#   的伤害，持续至其停留的水迹消失。"
# 【★ 先筛再打 ★】`@e[tag=zx.rt_lnk]` 是所有摊的受害者并集，用编号逐个比对后打
#   zx.rt_hit，最后只对 zx.rt_hit 出手 —— with_from 的 target 就必须是这一批。
# 【★ 选目标一定要带 distance=0.. ★】裸 @e 会跨维度；distance=0.. 只是给选择器
#   一个"就在这个维度里"的基准(见 fill 里同样的写法)。
# ============================================================

scoreboard players set @s zx.rt_beat 20
execute unless score @s zx.rt_ol matches 1 run return 0

scoreboard players operation #rt_mypid zx.meta = @s zx.rt_pid
tag @e[tag=zx.rt_lnk,distance=0..] remove zx.rt_hit
execute as @e[tag=zx.rt_lnk,distance=0..] if score @s zx.rt_pid = #rt_mypid zx.meta run tag @s add zx.rt_hit
execute unless entity @e[tag=zx.rt_hit,distance=0..] run return 0

# 伤害 = 释放者基础攻击力 ×2（这摊水迹出生那一刻的快照）
data modify storage zx:work a set value {target:"@e[tag=zx.rt_hit,distance=0..]",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from entity @s data.zx.dmg
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from entity @s data.zx.s2_b_dmg
function fallendream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function fallendream:internal/attack/submit_extra

# 表现（只冒一点水色，不盖模型）
execute at @e[tag=zx.rt_hit,distance=0..] run particle minecraft:dust{color:[0.25,0.5,0.72],scale:1.0} ~ ~0.6 ~ 0.35 0.35 0.35 0 5 normal
execute at @e[tag=zx.rt_hit,distance=0..] run playsound minecraft:block.bubble_column.upwards_inside player @a ~ ~ ~ 0.35 1.4
tag @e[tag=zx.rt_hit,distance=0..] remove zx.rt_hit
