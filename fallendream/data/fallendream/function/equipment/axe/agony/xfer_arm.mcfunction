# ============================================================
# fallendream:equipment/axe/agony/xfer_arm —— 苦痛·超限：开 4 秒转移窗口
# ------------------------------------------------------------
# 【谁调用它】cast ③（超限 + 效果仍在生效时的"再按一次"）
# 【执行者】玩家
# 【文案】使用技能期间再次使用技能后在 4 秒内攻击一个其他生物则可以把本武器技能
#   效果转移到该生物上，且持续时间 +1 秒，每个技能期间只能使用一次。
# 【★ 不计"已用"★】这里只开窗；zx.ag_xn=1 由 xfer 在**真的转移成功**那一刻才置上，
#   否则开窗后 4 秒没打到人就白丢一次机会（文案限制的是"使用一次"= 转移）。
# ============================================================

# 本轮已经转移过 ⇒ 只提示，不重复开窗
execute if score @s zx.ag_xn matches 1 run tellraw @s {"text":"本轮苦痛已经转移过一次了。","color":"red"}
execute if score @s zx.ag_xn matches 1 run return 0

scoreboard players operation @s zx.ag_xfer = #now manacore.meta
scoreboard players add @s zx.ag_xfer 80

tellraw @s {"text":"4 秒内攻击另一个生物，可把苦痛转移到它身上。","color":"light_purple"}
execute at @s run particle minecraft:dust{color:[0.75,0.3,0.9],scale:1.2} ~ ~1 ~ 0.5 0.8 0.5 0.03 18 normal
execute at @s run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.7 1.4
