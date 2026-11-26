# 长愿 法球命中回调: @s=法球, 位置=命中点。
# 命中的生物若处于长愿领域(8 格)内, 记为"本次消耗标签后转移"的优先目标。
execute as @e[tag=zx.ball_hit,distance=0..4] at @s if entity @e[tag=zx.lw_field,distance=..8] run tag @s add zx.lw_prio
