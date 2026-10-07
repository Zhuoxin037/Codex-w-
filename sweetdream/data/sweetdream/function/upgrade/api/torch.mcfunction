# ============================================================
# sweetdream:upgrade/api/torch —— 「火炬」: 10% 把目标身上的「流火」转成「夜火」
# ------------------------------------------------------------
# 【谁调用它】upgrade/api/on_hit 的第 ④ 步(已确认主手这件装了 火炬)
# 【执行者】动手的玩家   【前置】调用方已经跑过 lib/victim, zx.victim = 刚被打的那只
# 【文案】攻击时若目标有「流火」效果，则有 10% 概率将其转换为「夜火」。
# 【★ 先钉进 zx.tc_c 再摘/加 ★】照抄 remelt/convert 那条血泪教训:
#   如果每一步都写 `if entity @e[...,tag=zx.status.liuhuo]`, 那第一步把流火摘了之后
#   后面"附夜火"的条件就不成立了 —— 结果是"流火没了、夜火也没上"。
# 【★ 不走 lib/mark_consume ★】这是**转换**不是**消耗**: 走消耗入口的话,
#   穿「永恒」的玩家会把流火"补回来", 变成流火+夜火双状态(刷魔力漏洞)。
#   所以和热熔一样直调 tag/unmark + tag/mark。
# ============================================================

# ① 掷一次骰子(无论如何都掷, 保持随机序列连续)
function sweetdream:lib/rnd
scoreboard players operation #tc_r zx.meta = #rnd zx.meta
scoreboard players operation #tc_r zx.meta %= #10 zx.meta

# ② 命中 0(1/10) 且目标确实带「流火」-> 钉进 zx.tc_c
tag @e[tag=zx.tc_c] remove zx.tc_c
execute if score #tc_r zx.meta matches 0 run tag @e[tag=zx.victim,tag=zx.status.liuhuo,limit=1] add zx.tc_c

# ③ 摘流火、附夜火
execute if entity @e[tag=zx.tc_c] run data modify storage zx:work ic set value {target:"@e[tag=zx.tc_c]",mark:"liuhuo"}
execute if entity @e[tag=zx.tc_c] run function sweetdream:tag/unmark with storage zx:work ic
execute if entity @e[tag=zx.tc_c] run data modify storage zx:work ic set value {target:"@e[tag=zx.tc_c]",mark:"yehuo"}
execute if entity @e[tag=zx.tc_c] run function sweetdream:tag/mark with storage zx:work ic

# ④ 表现
execute at @e[tag=zx.tc_c] run particle minecraft:soul_fire_flame ~ ~1 ~ 0.5 0.6 0.5 0.03 14 normal
execute at @e[tag=zx.tc_c] run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.5 1.7

tag @e[tag=zx.tc_c] remove zx.tc_c
