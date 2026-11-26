# ============================================================
# fallendream:equipment/armor/breathing_soil/ol_end —— 超限·息土：领域结束结算
# ------------------------------------------------------------
# 【谁调用它】breathing_soil/field_end ①（领域倒计时归零那一刻，执行者 = 玩家）
# 【文案(逐字)】"…领域结束时自身若还在领域内则自身恢复 12% 生命值，若生命值已满则
#   该装备的冷却时间 -10 秒。"
# 【★ "还在领域内"怎么判 ★】开阵那一秒把玩家坐标记成 zx.so_x/y/z（×100 定点）,
#   这里读当前坐标做差；领域半径 8 格 ⇒ 三个轴都在 ±800 以内就算还在里面。
#   用 +-8 格的立方体近似球体 —— 与包里其它"半径 N 格"字段的选择器口径一致。
# 【★ 顺序: 先判在不在, 再判满没满 ★】"满血"是"在领域里"的子情况;
#   反过来的话满血的人会先吃到 12% 回血(回了 0 点)再也不会减冷却。
# ============================================================

# ① 还在领域内吗（三个轴逐一比）
scoreboard players set #so_ok zx.meta 0
scoreboard players set #so_c zx.meta 0
execute store result score #so_c zx.meta run data get entity @s Pos[0] 100
scoreboard players operation #so_d zx.meta = #so_c zx.meta
scoreboard players operation #so_d zx.meta -= @s zx.so_x
execute if score #so_d zx.meta matches -800..800 run scoreboard players set #so_ok zx.meta 1
scoreboard players set #so_ok2 zx.meta 0
execute store result score #so_c zx.meta run data get entity @s Pos[1] 100
scoreboard players operation #so_d zx.meta = #so_c zx.meta
scoreboard players operation #so_d zx.meta -= @s zx.so_y
execute if score #so_d zx.meta matches -800..800 run scoreboard players set #so_ok2 zx.meta 1
scoreboard players set #so_ok3 zx.meta 0
execute store result score #so_c zx.meta run data get entity @s Pos[2] 100
scoreboard players operation #so_d zx.meta = #so_c zx.meta
scoreboard players operation #so_d zx.meta -= @s zx.so_z
execute if score #so_d zx.meta matches -800..800 run scoreboard players set #so_ok3 zx.meta 1
execute unless score #so_ok zx.meta matches 1 run return 0
execute unless score #so_ok2 zx.meta matches 1 run return 0
execute unless score #so_ok3 zx.meta matches 1 run return 0

# ② 满血 -> 冷却 -10 秒（= 200 刻），夹到"不早于现在"
function fallendream:lib/hp_pct
execute if score #hp_p100 zx.meta matches 10000 run scoreboard players remove @s zx.so_cd 200
execute if score #hp_p100 zx.meta matches 10000 if score @s zx.so_cd < #now manacore.meta run scoreboard players operation @s zx.so_cd = #now manacore.meta
execute if score #hp_p100 zx.meta matches 10000 at @s run particle minecraft:happy_villager ~ ~1 ~ 0.4 0.4 0.4 0.02 8 normal

# ③ 未满血 -> 恢复 12% 最大生命值
execute if score #hp_p100 zx.meta matches 10000 run return 0
function fallendream:lib/max_health_score
execute unless score #max_hp zx.meta matches 1.. run return 0
scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players set #mp_mul zx.meta 120
function fallendream:lib/math/mul_permille
scoreboard players set #so_k zx.meta 1000
scoreboard players operation #mp_out zx.meta /= #so_k zx.meta
execute unless score #mp_out zx.meta matches 1.. run scoreboard players set #mp_out zx.meta 1
scoreboard players operation #heal_pt zx.meta = #mp_out zx.meta
function fallendream:lib/heal
execute at @s run particle minecraft:heart ~ ~1.1 ~ 0.5 0.4 0.5 0.01 5 normal
