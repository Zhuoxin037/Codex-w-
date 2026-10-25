# ============================================================
# sweetdream:equipment/staff/fate_thread/ol_tighten —— 命缕超限：丝线将断时绷紧一次（第一组）
# ------------------------------------------------------------
# 【谁调用】watch（第一组 12 秒到期那一刻）
# 【执行者】施法者   【位置】玩家所在
# 【文案】"丝线随时间即将结束时则绷紧一次并对连接的全部生物造成一次
#   10 × 连接的生物数 点固定真实伤害并使其附加「噬心」。"
# 【打谁】第一组的全部成员 = 主目标 + zx.ft_lk（同实例号）。
#   ★ 绷紧是"固定真实伤害"，不参与任何乘区 ⇒ 直接给数值 + type=true_damage，
#     走 api/damage（不带 fixed:1b 也行，真伤本身已绕过受击侧加成里的技能/普攻分支；
#     这里仍标 fixed:1b 更保险：噬心/夜火那几条都判 fixed 排除）。
# ============================================================

tag @e[tag=zx.ft_tg,distance=0..] remove zx.ft_tg
execute as @e[tag=zx.ft_main] if score @s zx.ft_n = #ft_iid zx.meta run tag @s add zx.ft_tg
execute as @e[tag=zx.ft_lk] if score @s zx.ft_n = #ft_iid zx.meta run tag @s add zx.ft_tg

# 连接的生物数 → 10 × N（先清零再逐个 +1：计分项"没分数"不是 0）
scoreboard players set #ft_tn zx.meta 0
execute as @e[tag=zx.ft_tg,distance=0..] run scoreboard players add #ft_tn zx.meta 1
scoreboard players operation #ft_tn zx.meta *= #10 zx.meta

data modify storage zx:in arg set value {target:"@e[tag=zx.ft_tg,distance=0..]",damage:0.0,type:"sweetdream:true_damage",fixed:1b}
execute store result storage zx:in arg.damage double 1.0 run scoreboard players get #ft_tn zx.meta
execute at @s run function sweetdream:api/damage

# 附加「噬心」（受管状态：带 TTL / 图标）
data modify storage zx:work ic set value {target:"@e[tag=zx.ft_tg,distance=0..]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

execute at @e[tag=zx.ft_tg,distance=0..] run particle minecraft:dust{color:[1.0,0.18,0.28],scale:1.8} ~ ~1 ~ 0.5 0.6 0.5 0.02 20 normal
execute at @s run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.9 1.2
tag @e[tag=zx.ft_tg,distance=0..] remove zx.ft_tg
