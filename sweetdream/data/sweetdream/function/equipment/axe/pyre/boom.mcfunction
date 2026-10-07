# ============================================================
# sweetdream:equipment/axe/pyre/boom —— 葬火第二段: 自身 5 格内 X×0.5 点伤害
# ------------------------------------------------------------
# 【谁调用它】pyre/tick(倒计时归零)
# 【执行者】玩家  【位置】玩家当前所在处(文案是"对自身 5 格范围内", 以**当时**的自己为圆心)
# 【数值】X×0.5 = zx.py_x × 5 ÷ 10
# ============================================================

scoreboard players operation #py_d zx.meta = @s zx.py_x
scoreboard players operation #py_d zx.meta *= #5 zx.meta
scoreboard players operation #py_d zx.meta /= #10 zx.meta

data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..5]",damage:0.0}
execute store result storage zx:in arg.damage double 1 run scoreboard players get #py_d zx.meta
execute at @s run function sweetdream:api/damage

# 收尾: X 清 0(观测镜「葬火」那一段随之消失)
scoreboard players set @s zx.py_x 0

# 表现
execute at @s run particle minecraft:flame ~ ~0.2 ~ 2.6 0.3 2.6 0.08 60 normal
execute at @s run particle minecraft:large_smoke ~ ~0.2 ~ 2.6 0.3 2.6 0.05 40 normal
execute at @s run playsound minecraft:entity.generic.explode player @a ~ ~ ~ 1.0 0.7
