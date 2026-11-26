# ============================================================
# fallendream:equipment/armor/falling_deep/spawn —— 落溟：生成领域 marker
# ------------------------------------------------------------
# 【谁调用它】falling_deep/cast ③
# 【执行者】玩家   【执行位置】用 execute at @s 锁到玩家自身位置
# 【本体】marker 带标签 zx.fd_field，计分项 zx.fd_end = 生成刻 +100（5 秒）
# ============================================================

execute at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.fd_field","zx.fd_new"]}
execute at @s as @e[tag=zx.fd_new,distance=..1,limit=1] run scoreboard players operation @s zx.fd_end = #now manacore.meta
execute at @s as @e[tag=zx.fd_new,distance=..1,limit=1] run scoreboard players add @s zx.fd_end 100
execute at @s run tag @e[tag=zx.fd_new,distance=..1] remove zx.fd_new
execute at @s run particle minecraft:enchant ~ ~0.3 ~ 1.2 0.2 1.2 0.03 16 normal
