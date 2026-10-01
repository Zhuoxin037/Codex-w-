# ============================================================
# sweetdream:lib/unfreeze_one —— 解冻一只生物(执行者 = 被冻的那只)
# 【三件事】TicksFrozen 归零 / 摘掉速度属性乘区 / 摘 zx.freeze
# 【计时】只清自己的 zx.fz_end(时停有自己的 zx.ts_end, 不用管)
# ============================================================

data modify entity @s TicksFrozen set value 0
attribute @s minecraft:movement_speed modifier remove sweetdream:freeze
tag @s remove zx.freeze
scoreboard players reset @s zx.fz_end