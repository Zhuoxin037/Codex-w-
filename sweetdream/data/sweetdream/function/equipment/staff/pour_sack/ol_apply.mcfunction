# ============================================================
# sweetdream:equipment/staff/pour_sack/ol_apply —— 倾囊超限：把追伤并进这一笔的 fixed_add
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one（在 fixed_add 那段**之前**）
# 【执行者】被打的那一只
# 【怎么并】a.fixed_add 可能已经有值（别的装备的固定附伤），这里做加法而不是覆盖；
#   之后 one 里现成的 `if a.fixed_add -> internal/damage/fixed_add` 会把它加进 a.num，
#   再重算 num_str —— 不需要在这里重算。
# 【★ 用完立刻清 psadd ★】它是"这一笔"的临时量，留下来会串到下一笔（同一个 tick
#   里往往连着打好几只）。
# ============================================================
scoreboard players set #ps_ba zx.meta 0
execute store result score #ps_ba zx.meta run data get storage zx:work a.fixed_add 1000
scoreboard players set #ps_bn zx.meta 0
execute store result score #ps_bn zx.meta run data get storage zx:work psadd 1000
scoreboard players operation #ps_ba zx.meta += #ps_bn zx.meta
execute store result storage zx:work a.fixed_add double 0.001 run scoreboard players get #ps_ba zx.meta
data remove storage zx:work psadd
