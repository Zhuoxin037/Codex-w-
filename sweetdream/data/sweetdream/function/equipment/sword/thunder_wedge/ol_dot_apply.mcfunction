# ============================================================
# sweetdream:equipment/sword/thunder_wedge/ol_dot_apply —— 超限·雷楔: 给被雷命中的生物挂 DoT
# ------------------------------------------------------------
# 【执行者】被闪电命中的生物(1 格内, 与主伤同一批)
# 【调用方】strike ④.5(平 A 触发的那道雷) / ol_end_one ③(结束那场范围雷)
# 【两档】
#   · 首次命中: zx.twg_dot=3, zx.twg_dotk=1  -> 3 秒内每秒 当前魔力×0.07
#   · 期间再被雷命中: zx.twg_dot=5, zx.twg_dotk=2 -> 5 秒内每秒 最大魔力×0.08
# 【★ 先 `add … 0` 再判档 ★】计分项"没有分数"时 `matches ..0` 也不成立
#   (没分数 ≠ 0)。不补这一行, 第一次命中会两段都不进 = DoT 永远挂不上, 且不报错。
# 【★ 强化只能往上, 不能往下 ★】已经是 2 档的再被命中, 只续 5 秒、不掉回 1 档。
# ============================================================

scoreboard players add @s zx.twg_dot 0
scoreboard players add @s zx.twg_dotk 0

# ① 已经有 DoT(不管哪一档) -> 强化档 + 续到 5 秒
execute if score @s zx.twg_dot matches 1.. run scoreboard players set @s zx.twg_dotk 2
execute if score @s zx.twg_dot matches 1.. run scoreboard players set @s zx.twg_dot 5

# ② 首次命中 -> 普通档 + 3 秒
execute if score @s zx.twg_dot matches ..0 run scoreboard players set @s zx.twg_dotk 1
execute if score @s zx.twg_dot matches ..0 run scoreboard players set @s zx.twg_dot 3

# 表现: 雷痕贴在身上
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.25 0.5 0.25 0.05 8 normal
