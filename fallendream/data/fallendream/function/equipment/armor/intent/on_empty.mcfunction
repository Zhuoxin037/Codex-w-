# ============================================================
# fallendream:equipment/armor/intent/on_empty —— 临时生命清空 → 抗性Ⅱ + 迅捷Ⅲ
# ------------------------------------------------------------
# 【谁调用它】lib/thp/clear（临时生命被清空的那一刻；执行者 = 玩家）
# 【文案】自身临时生命值清空后，获得 5 秒抗性提升Ⅱ和迅捷Ⅲ；该效果每 12 秒最多触发一次。
# 【★ 12 秒冷却 ★】zx.it_cd = 下次可触发的刻；没分数时 `> #now` 判失败 ⇒ 第一次放行。
# 【★ 摘掉「蓄意」之后不会再给 ★】穿着门控放第一行。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run return 0
# ---- 超限(2026-11-22): 三段式(基础层 → 额外层 → 额外层刷新), 没有 12 秒节流 ----
#   超限文案把这一整段重写了("该效果持续期间若再次触发…"), 7 秒里要能触发第二次,
#   所以基础版的 12 秒冷却在这里**不适用**; 基础版分支原样不动。
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"],ol:"intent"}] run function fallendream:equipment/armor/intent/ol_empty
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"],ol:"intent"}] run return 0
execute if score @s zx.it_cd > #now manacore.meta run return 0

scoreboard players operation @s zx.it_cd = #now manacore.meta
scoreboard players add @s zx.it_cd 240

effect give @s minecraft:resistance 5 1 true
effect give @s minecraft:speed 5 2 true

tellraw @s [{"text":"「蓄意」","color":"gold"},{"text":"  临时生命清空 —— 抗性提升Ⅱ、迅捷Ⅲ（5 秒）","color":"gray"}]
particle minecraft:totem_of_undying ~ ~1 ~ 0.4 0.6 0.4 0.1 12 normal
