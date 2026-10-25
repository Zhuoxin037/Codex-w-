# ============================================================
# sweetdream:equipment/staff/fate_thread/ol_tighten2 —— 命缕超限：第二组绷紧（18 秒到期）
# ------------------------------------------------------------
# 【谁调用】watch_end（收场前，超限且第二组还有成员时）
# 【执行者】施法者   【位置】玩家所在
# 【打谁】zx.ft_lk2 里属于本实例的生物（主目标此时已被第一组绷紧打过一次，
#   若它同时在第二组里，会再吃一次 —— 文案是"连接的全部生物"，两组各绷一次，
#   同一只被两条丝连着就是两次，属于预期）。
# 【★ 与 ol_tighten 的区别 ★】只按 zx.ft2n 认人，且不把主目标硬拉进来。
# ============================================================

tag @e[tag=zx.ft_tg,distance=0..] remove zx.ft_tg
execute as @e[tag=zx.ft_lk2] if score @s zx.ft2n = #ft_iid zx.meta run tag @s add zx.ft_tg
execute unless entity @e[tag=zx.ft_tg,distance=0..,limit=1] run return 0

scoreboard players set #ft_tn zx.meta 0
execute as @e[tag=zx.ft_tg,distance=0..] run scoreboard players add #ft_tn zx.meta 1
scoreboard players operation #ft_tn zx.meta *= #10 zx.meta

data modify storage zx:in arg set value {target:"@e[tag=zx.ft_tg,distance=0..]",damage:0.0,type:"sweetdream:true_damage",fixed:1b}
execute store result storage zx:in arg.damage double 1.0 run scoreboard players get #ft_tn zx.meta
execute at @s run function sweetdream:api/damage

data modify storage zx:work ic set value {target:"@e[tag=zx.ft_tg,distance=0..]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

execute at @e[tag=zx.ft_tg,distance=0..] run particle minecraft:dust{color:[1.0,0.18,0.28],scale:1.8} ~ ~1 ~ 0.5 0.6 0.5 0.02 20 normal
execute at @s run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.9 1.2
tag @e[tag=zx.ft_tg,distance=0..] remove zx.ft_tg
