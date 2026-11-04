# ============================================================
# sweetdream:equipment/sword/sacrifice/second —— 牺牲：每秒放血 + 到点收尾
# ------------------------------------------------------------
# 【执行者】玩家
# 【参数】zx.sc_on=1 · zx.sc_dps（毫点/秒）· zx.sc_floor（目标血量毫点）· zx.sc_until
# 【★ 走 damage 而不是改 Health ★】原版禁止命令改玩家 NBT。
#   用 sweetdream:parallel_true_damage（真伤类型，不吃护甲）—— 文案是"流血"，
#   每滴都是净损失，不该被减伤。
# ============================================================

execute unless score @s zx.sc_on matches 1 run return 0

# 到点，或已经掉到 20% → 收尾
execute if score @s zx.sc_until <= #now manacore.meta run function sweetdream:equipment/sword/sacrifice/end
execute unless score @s zx.sc_on matches 1 run return 0
execute if score @s zx.hp_c <= @s zx.sc_floor run function sweetdream:equipment/sword/sacrifice/end
execute unless score @s zx.sc_on matches 1 run return 0

# 本秒掉血（不会一次跨过目标线）
scoreboard players operation #sc_step zx.meta = @s zx.sc_dps
scoreboard players operation #sc_left zx.meta = @s zx.hp_c
scoreboard players operation #sc_left zx.meta -= @s zx.sc_floor
execute if score #sc_step zx.meta > #sc_left zx.meta run scoreboard players operation #sc_step zx.meta = #sc_left zx.meta
execute if score #sc_step zx.meta matches ..0 run return 0
execute store result storage zx:work sc.v double 0.001 run scoreboard players get #sc_step zx.meta
function sweetdream:equipment/sword/sacrifice/bleed with storage zx:work sc
