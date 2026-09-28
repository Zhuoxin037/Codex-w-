# ============================================================
# sweetdream:equipment/staff/wind_ontheground/aura_tick —— 风声回响的每秒心跳
# ------------------------------------------------------------
# 【宏参数】zx:work wg {uuid}   【执行者】施法者
# 【节奏】站在 20 秒里打 5 次 -> 剩 20/16/12/8/4 秒时各打一次(间隔 4 秒)。
#   4 秒远大于生物的受伤无敌帧(0.5 秒), 所以 5 次伤害一次都不会被吃掉。
# 【结束时】aura 归 0 -> 交给 end 收尾(摘最大魔力加成 + 清空风声)。
# ============================================================

execute if score @s zx.wg_aura matches 20 run function sweetdream:equipment/staff/wind_ontheground/aura_hit with storage zx:work wg
execute if score @s zx.wg_aura matches 16 run function sweetdream:equipment/staff/wind_ontheground/aura_hit with storage zx:work wg
execute if score @s zx.wg_aura matches 12 run function sweetdream:equipment/staff/wind_ontheground/aura_hit with storage zx:work wg
execute if score @s zx.wg_aura matches 8 run function sweetdream:equipment/staff/wind_ontheground/aura_hit with storage zx:work wg
execute if score @s zx.wg_aura matches 4 run function sweetdream:equipment/staff/wind_ontheground/aura_hit with storage zx:work wg

scoreboard players remove @s zx.wg_aura 1
execute if score @s zx.wg_aura matches ..0 run function sweetdream:equipment/staff/wind_ontheground/end with storage zx:work wg
