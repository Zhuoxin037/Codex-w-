# ============================================================
# fallendream:equipment/axe/thunderclap/maxloss —— 威霆: 每 10 次雷击, 损失 10% 最大生命
# ------------------------------------------------------------
# 【谁调用它】thunderclap/bolt_go(本次跨过的"10 的倍数"次数 = #tc_n2)
# 【执行者】术阵 marker  【打谁】zx.victim
# 【数值】次数 × (被击者自身最大生命 × 10%) —— 逐次等价于扣 10% 最大生命。
# ============================================================

$execute store result score #tc_hp zx.meta run attribute $(vx_uuid) minecraft:max_health get
scoreboard players operation #tc_hp zx.meta *= #tc_n2 zx.meta
scoreboard players operation #tc_hp zx.meta /= #10 zx.meta

$data modify storage zx:in arg set value {target:"$(vx_uuid)",damage:0.0}
execute store result storage zx:in arg.damage double 1 run scoreboard players get #tc_hp zx.meta
$execute at $(vx_uuid) run function fallendream:internal/attack/api_extra
