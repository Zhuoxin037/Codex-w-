# ============================================================
# fallendream:equipment/armor/intent/ol_empty —— 超限·蓄意：临时生命清空的三段式
# ------------------------------------------------------------
# 【谁调用它】intent/on_empty（临时生命被清空那一刻；执行者 = 玩家）
# 【文案】当自身的临时生命值清空后自身获得 7 秒抗性提升2和迅捷3，该效果持续期间若再次
#   触发则自身额外获得 10 秒抗性提升4和最大生命值 +10%，若此期间再次触发则该效果
#   重置为 10 秒。
# 【三段】zx.it_a_end = 基础层(7 秒)到期刻; zx.it_b_end = 额外层(10 秒)到期刻。
#   ① 额外层还在 → 只把 10 秒刷新一遍(抗性Ⅳ 与生命上限都不叠, "重置为 10 秒")
#   ② 只有基础层 → 开额外层: 抗性Ⅳ 10 秒 + max_health ×1.1
#   ③ 都没有 → 基础层: 抗性Ⅱ + 迅捷Ⅲ 各 7 秒
# 【★ 顺序不能换 ★】① 必须先判: 额外层生效时基础层一定也在(它是在基础层里开的),
#   先判基础层会把它永远当成"第二次", 于是 10 秒窗口再也刷不新。
# 【★ 抗性Ⅳ 用 effect 不记账 ★】到期由原版自己收; 只有 max_health 的 modifier
#   不会自己消失, 所以它由 second 每秒判 it_b_end 撤。
# 【★ modifier 先 remove 再 add ★】重复 add 同名会失败(不是顶掉), 那样第二次触发
#   就拿不到那 10% 了。
# ============================================================

scoreboard players set #it_a zx.meta 0
execute if score @s zx.it_a_end > #now manacore.meta run scoreboard players set #it_a zx.meta 1
scoreboard players set #it_b zx.meta 0
execute if score @s zx.it_b_end > #now manacore.meta run scoreboard players set #it_b zx.meta 1

# ---- ① 额外层期间再次触发: 重置为 10 秒 ----
execute if score #it_b zx.meta matches 1 run scoreboard players operation @s zx.it_b_end = #now manacore.meta
execute if score #it_b zx.meta matches 1 run scoreboard players add @s zx.it_b_end 200
execute if score #it_b zx.meta matches 1 run effect give @s minecraft:resistance 10 3 true
execute if score #it_b zx.meta matches 1 run tellraw @s [{"text":"「蓄意」","color":"gold"},{"text":"  额外效果重置 —— 抗性提升Ⅳ、最大生命 +10%（10 秒）","color":"gray"}]
execute if score #it_b zx.meta matches 1 run return 0

# ---- ② 基础层期间再次触发: 额外 10 秒抗性Ⅳ + 最大生命 +10% ----
execute if score #it_a zx.meta matches 1 run scoreboard players operation @s zx.it_b_end = #now manacore.meta
execute if score #it_a zx.meta matches 1 run scoreboard players add @s zx.it_b_end 200
execute if score #it_a zx.meta matches 1 run effect give @s minecraft:resistance 10 3 true
execute if score #it_a zx.meta matches 1 run attribute @s minecraft:max_health modifier remove fallendream:it_hp2
execute if score #it_a zx.meta matches 1 run attribute @s minecraft:max_health modifier add fallendream:it_hp2 0.1 add_multiplied_total
execute if score #it_a zx.meta matches 1 run tellraw @s [{"text":"「蓄意」","color":"gold"},{"text":"  额外效果 —— 抗性提升Ⅳ、最大生命 +10%（10 秒）","color":"gray"}]
execute if score #it_a zx.meta matches 1 run particle minecraft:totem_of_undying ~ ~1 ~ 0.5 0.7 0.5 0.12 18 normal
execute if score #it_a zx.meta matches 1 run return 0

# ---- ③ 基础层: 抗性Ⅱ + 迅捷Ⅲ, 7 秒 ----
scoreboard players operation @s zx.it_a_end = #now manacore.meta
scoreboard players add @s zx.it_a_end 140
effect give @s minecraft:resistance 7 1 true
effect give @s minecraft:speed 7 2 true
tellraw @s [{"text":"「蓄意」","color":"gold"},{"text":"  临时生命清空 —— 抗性提升Ⅱ、迅捷Ⅲ（7 秒）","color":"gray"}]
particle minecraft:totem_of_undying ~ ~1 ~ 0.4 0.6 0.4 0.1 12 normal
