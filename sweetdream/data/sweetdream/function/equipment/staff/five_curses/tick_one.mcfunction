# ============================================================
# sweetdream:equipment/staff/five_curses/tick_one —— 一只生物的世咒倒计时
# ------------------------------------------------------------
# 【执行者】带世咒的那只生物(@s)    【调用者】second(三个维度各扫一遍后逐只进来)
# 【为什么单独拆出来】second 里三个维度都要跑同一段逻辑, 写成三条 `execute ... run
#   function 本文件` 比把四行逻辑抄三遍干净, 也避免以后改一处漏两处。
# ============================================================

# ⓪ 第四世破甲的**独立**倒计时(文案: 降低 50%, **持续 5 秒**)
#   ★ 必须排在下面的 `return 0` **之前** —— 早退会把这一段整段跳过(世咒还没到期时
#     正是最常见的情况, 那样破甲就永远不会自己摘)。
#   ★ 门控用标签 zx.fcv_4(="当前正挂着破甲"), 没挂的目标不参与, 开销为零。
execute if entity @s[tag=zx.fcv_4] run scoreboard players remove @s zx.fcv_t4 1
execute if entity @s[tag=zx.fcv_4] if score @s zx.fcv_t4 matches ..0 run function sweetdream:equipment/staff/five_curses/armor_uncut

scoreboard players remove @s zx.fcv_t 1

# 还没到点 → 收工
execute if score @s zx.fcv_t matches 1.. run return 0

# 到点了: 第五世走终世(30%, 比例由 second 预设), 其余直接清掉
execute if score @s zx.fcv_st matches 5 run function sweetdream:equipment/staff/five_curses/final
execute unless score @s zx.fcv_st matches 5 run function sweetdream:equipment/staff/five_curses/clear
