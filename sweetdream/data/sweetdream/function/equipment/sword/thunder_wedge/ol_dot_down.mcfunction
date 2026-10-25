# ============================================================
# sweetdream:equipment/sword/thunder_wedge/ol_dot_down —— 超限·雷楔 DoT 每秒 -1
# ------------------------------------------------------------
# 【谁调用它】lib/second 的三维度扫描(见那里的注释)
# 【执行者】带 DoT 的生物(选择器已经按 scores={zx.twg_dot=1..} 筛过, 不会减到 0 以下)
# 【★ 为什么必须有这一份"雷楔之外"的计时 ★】
#   雷楔只活 10 秒, 而强化档的 DoT 是 5 秒 —— 完全可能比雷楔活得久。
#   如果秒数只在 ol_tick 里减, 雷楔一死那些生物就永久停在"每秒掉血"的状态:
#   分数不再推进、伤害不再结算、也没有任何东西会去清它 —— 这就是
#   RULES「临时状态用计分项的铁律」里说的泄漏(存档可验证: 无雷楔却有 zx.twg_dot)。
# 【三件一起清】dot / dotk 都归 0(0 = 未激活)。不掉标签: 这套状态本来就只用计分项。
# ============================================================

scoreboard players remove @s zx.twg_dot 1
execute if score @s zx.twg_dot matches ..0 run scoreboard players set @s zx.twg_dotk 0
execute if score @s zx.twg_dot matches ..0 run scoreboard players set @s zx.twg_dot 0
