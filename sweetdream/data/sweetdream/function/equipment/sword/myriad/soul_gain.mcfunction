# ============================================================
# sweetdream:equipment/sword/myriad/soul_gain —— 召唤一个「剑魂」(最多 5 个)
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】若攻击到生物则召唤一个“剑魂”（最多为 5 个）。
# 【★ 剑魂是"计数资源"不是实体 ★】它的作用全靠计数体现("每有一个剑魂则技能
#   伤害重复一次" / "有 5 个则进居合"), 所以实装成**玩家计分项 zx.mq_soul**;
#   视觉那部分由 soul_fx 每刻绕着玩家画剑形粒子 —— 两者分开, 不会因为实体
#   被清/换维度而让计数和画面对不上。
# ============================================================

scoreboard players add @s zx.mq_soul 0
execute if score @s zx.mq_soul matches ..4 run scoreboard players add @s zx.mq_soul 1
execute at @s run particle minecraft:sweep_attack ~ ~1 ~ 0.6 0.6 0.6 0.02 6 normal
execute at @s run playsound minecraft:item.trident.return player @a ~ ~ ~ 0.5 1.6
