# ============================================================
# sweetdream:lib/thp/tick —— 临时生命每秒维护（到期 / 被打空）
# ------------------------------------------------------------
# 【谁调用它】lib/second：execute as @a[scores={zx.thp=1..}] run ...
# 【执行者】玩家(@s)
# 【两件事】
#   ① 到期：zx.thp_end ≤ #now ⇒ clear（效果 60 秒的兜底）。
#   ② 被打空：读 AbsorptionAmount（×100），≤0 而账本还在 ⇒ 视为清空。
#      ★ 这是全包唯一读玩家 NBT 的每秒路径，且只对"身上真挂着临时生命"的人跑
#        （选择器先按 zx.thp 过滤），通常 0~2 人。
# 【★ 检测顺延一拍 ★】清空发生在本刻受伤时，吸收值要到本刻 tickEffects 之后才变；
#   这里每秒检查一次，最晚 1 秒后被发现 —— 蓄意的"清空后给抗性/迅捷"按秒粒度
#   触发是文案允许的（"该效果每 12 秒最多触发一次"，没有更细的要求）。
# ============================================================

# ① 到期
execute if score @s zx.thp_end <= #now manacore.meta run function sweetdream:lib/thp/clear

# ② 被打空（账本还在才读 NBT）
execute unless entity @s[tag=zx.thp_on] run return 0
scoreboard players set #thp_real zx.meta 0
execute store result score #thp_real zx.meta run data get entity @s AbsorptionAmount 100
execute if score #thp_real zx.meta matches ..0 run function sweetdream:lib/thp/clear
