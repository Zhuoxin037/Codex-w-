# @s = 观察 marker。宏 victim = 精确受害者 UUID。
# 使用 UUID 字面量直接查询, 不用 @e[nbt={Health:0}] 或非法 DeathTime 范围。
$execute as $(victim) at @s if data entity @s {Health:0.0f} run function sweetdream:equipment/axe/sacred_relic/relic_spawn
