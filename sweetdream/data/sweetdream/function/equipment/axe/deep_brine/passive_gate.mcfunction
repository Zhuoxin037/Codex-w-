# ============================================================
# sweetdream:equipment/axe/deep_brine/passive_gate —— 重溟被动"同一生物 10 秒一次"的闸
# ------------------------------------------------------------
# 【执行者】刚被平A打中、且确实带着「渊海」的那只生物
# 【产出】放行 -> 给自己挂 zx.db_pass(调用方据此继续打伤害); 不放行 -> 什么都不做
# 【为什么记在生物身上】文案是"对**同一个生物** 10 秒内最多触发一次"。
#   玩家级计数挡不住"换个怪接着打" ⇒ 逐目标节流必须有**生物自己的计分项**
#   (RULES: 先例 zx.stg; 同构先例 = 余烬 ember/top_up 的 zx.em_gate)。
# 【记录方式】zx.db_pd = 该生物"下次可以触发"的 #now 时刻 = 现在 + 200 刻(= 10 秒)。
#   #now 是 manacore 的持久化 tick 计数; #200 是 core/load 常量表里的 200(10 秒)。
# 【★ 先 add 0 ★】计分项"没分数"时 `if score` 判**不成立**, 不能靠"没分数"表示
#   "从没触发过"(那样第一次永远触发不了) —— 余烬那道闸踩过同一个坑。
# ============================================================

scoreboard players add @s zx.db_pd 0
execute if score @s zx.db_pd > #now manacore.meta run return 0
scoreboard players operation @s zx.db_pd = #now manacore.meta
# 冷却间隔: 普通 200 刻(10 秒) / 超限 60 刻(3 秒)
#   #dbp_ol 是 hit_go ②.5 拍的(1 = 这一次拿的是超限·重溟)。
scoreboard players set #db_gap zx.meta 200
execute if score #dbp_ol zx.meta matches 1 run scoreboard players set #db_gap zx.meta 60
scoreboard players operation @s zx.db_pd += #db_gap zx.meta
tag @s add zx.db_pass
