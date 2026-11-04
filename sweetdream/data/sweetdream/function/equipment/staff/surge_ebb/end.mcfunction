# ============================================================
# sweetdream:equipment/staff/surge_ebb/end —— 潮涌，潮枯：12 秒到，收场
# ------------------------------------------------------------
# 【执行者】释放者
# 【文案】结束后"追奉者"向自身收回，全部回收后使自身及自身 5 格内的全部玩家恢复全部生命值。
# 【★ 收回 = 直接 kill ★】追击者只是占位 marker，没有独立行为，kill 就是"收回"。
# 【★ 只收自己的 ★】按释放者 UUID 匹配 data.u0..u3（同 to_se / extend_go）。
# ============================================================

scoreboard players set @s zx.se_on 0
tag @s remove zx.se_c

execute store result storage zx:work se.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work se.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work se.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work se.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:equipment/staff/surge_ebb/recall_se with storage zx:work se

# 全部回收后回满（自身在 5 格内，天然包含）
execute at @s as @a[distance=..5] run function sweetdream:equipment/staff/surge_ebb/full_heal

execute at @s run particle minecraft:splash ~ ~1 ~ 1.6 0.6 1.6 0.2 50 normal
execute at @s run playsound minecraft:entity.player.splash player @a ~ ~ ~ 1.0 0.6
