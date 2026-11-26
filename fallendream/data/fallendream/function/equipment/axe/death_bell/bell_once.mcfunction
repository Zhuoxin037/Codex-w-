# ============================================================
# fallendream:equipment/axe/death_bell/bell_once —— 敲一次钟
# ------------------------------------------------------------
# 【谁调用它】dom_one ⑦⑧(连调两次)   【执行者】施法者   【位置】他所在处
# 【做什么】对已钉好的名单 zx.dbl_bell 全体:
#   ① 打一次 最大魔力值 ×0.08（超限 ×0.1；值已由 dom_one ⑥ 算好, 两次钟声同价）
#   ② 每命中一只就给 #dbl_n +1（原版的达标口径 = 命中次数合计）
#      同时给被打到的生物打 zx.dbl_x（超限的达标口径 = **不同**生物 ≥3）
#   ③ 3 秒虚弱Ⅱ(= amplifier 1, Ⅰ 才是 0)
#   ④ 表现
# 【超限新增】"若命中附有「白昼梦」的生物则消耗其「白昼梦」并将该次钟声改为真实伤害"
#   ⇒ 先在名单里挑出带 dream 的（zx.dbl_real）:
#     · 它们吃 fallendream:true_damage, 其余照旧走默认 skill 类型;
#     · 挨个消耗 dream（走 lib/mark_consume, @s 仍是施法者 ⇒ 永恒/余烬的判据不乱）。
#   ★ 两批互斥（tag=!zx.dbl_real / tag=zx.dbl_real），同一只不会被打两次。
# 【为什么名单不再挑一次】"释放两次钟声"= 对着同一批人敲两下, 不是每敲一次重新挑一批。
# ============================================================

# ⓪ 超限：挑出这一声里带「白昼梦」的目标
tag @e[tag=zx.dbl_real,distance=0..] remove zx.dbl_real
execute if score #dbl_ol zx.meta matches 1 as @e[tag=zx.dbl_bell,distance=0..,tag=zx.status.dream] run tag @s add zx.dbl_real

# ① 普通一段（原版 = 全体；超限 = 不带白昼梦的那些）
execute if score #dbl_ol zx.meta matches 0 run data modify storage zx:in arg set value {target:"@e[tag=zx.dbl_bell,distance=0..]",damage:0.0}
execute if score #dbl_ol zx.meta matches 1 run data modify storage zx:in arg set value {target:"@e[tag=zx.dbl_bell,tag=!zx.dbl_real,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work dbl.dmg2
data modify storage zx:in arg.s2_b_damage set value {n:0,d:1}
data modify storage zx:in arg.s2_b_damage set from storage zx:work dbl.s2_b_dmg2
execute at @s run function fallendream:internal/attack/api_skill

# ①.5 超限 · 带白昼梦的那批改真伤, 并消耗掉它的「白昼梦」
execute if score #dbl_ol zx.meta matches 1 if entity @e[tag=zx.dbl_real,distance=0..,limit=1] run data modify storage zx:in arg set value {target:"@e[tag=zx.dbl_real,distance=0..]",damage:0.0,type:"fallendream:true_damage"}
execute if score #dbl_ol zx.meta matches 1 if entity @e[tag=zx.dbl_real,distance=0..,limit=1] run data modify storage zx:in arg.damage set from storage zx:work dbl.dmg2
execute if score #dbl_ol zx.meta matches 1 if entity @e[tag=zx.dbl_real,distance=0..,limit=1] run data modify storage zx:in arg.s2_b_damage set value {n:0,d:1}
execute if score #dbl_ol zx.meta matches 1 if entity @e[tag=zx.dbl_real,distance=0..,limit=1] run data modify storage zx:in arg.s2_b_damage set from storage zx:work dbl.s2_b_dmg2
execute if score #dbl_ol zx.meta matches 1 if entity @e[tag=zx.dbl_real,distance=0..,limit=1] run function fallendream:internal/attack/api_skill

execute if score #dbl_ol zx.meta matches 1 if entity @e[tag=zx.dbl_real,distance=0..,limit=1] run data modify storage zx:work a set value {target:"@e[tag=zx.dbl_real,distance=0..]",mark:"dream"}
execute if score #dbl_ol zx.meta matches 1 if entity @e[tag=zx.dbl_real,distance=0..,limit=1] run function fallendream:lib/mark_consume

# ② 命中计数 + 不同生物打标（名单空则一次也不执行）
execute as @e[tag=zx.dbl_bell,distance=0..] run scoreboard players add #dbl_n zx.meta 1
execute as @e[tag=zx.dbl_bell,distance=0..] run tag @s add zx.dbl_x

# ③ 3 秒虚弱Ⅱ
execute as @e[tag=zx.dbl_bell,distance=0..] run effect give @s minecraft:weakness 3 1 true

# ④ 表现: 钟声的余音
execute at @e[tag=zx.dbl_bell,distance=0..,limit=1] run playsound minecraft:block.bell.resonate player @a ~ ~ ~ 0.9 0.7
particle minecraft:soul ~ ~1 ~ 1.2 0.6 1.2 0.01 10 normal
