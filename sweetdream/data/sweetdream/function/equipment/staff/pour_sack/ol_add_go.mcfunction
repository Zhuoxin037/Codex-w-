# ============================================================
# sweetdream:equipment/staff/pour_sack/ol_add_go —— 倾囊超限：算出这一笔要追多少
# ------------------------------------------------------------
# 【执行者】开着窗口的那名玩家（由 ol_add 用 UUID 反查出来）。
# 【★ 只写专用节点 zx:work psadd，不碰 ob ★】
#   ob 是"这一批伤害的不可变基准"，只有 with_from/one/stg_mul 能写它（check 规则盯着）。
#   真正的加算放在 one 里（ol_apply 把 psadd 加进 a.fixed_add）—— 那时 a 刚从 ob 复原，
#   加在 a 上是安全的，也不会反向污染基准。
# 【叠加而不是覆盖】同一笔上可能已经有别的固定值（如折径的 +18），psadd 只表示
#   "倾囊这一份额外要加多少"，两笔加在一起由 ol_apply 负责。
# ============================================================

scoreboard players set #ps_fx zx.meta 0
execute store result score #ps_fx zx.meta run scoreboard players get @s zx.ps_add
execute if score #ps_fx zx.meta matches 1.. run execute store result storage zx:work psadd double 1.0 run scoreboard players get #ps_fx zx.meta
