# ============================================================
# sweetdream:equipment/staff/other_shore/p_gate —— 彼岸附加效果的"同一生物 8 秒一次"闸
# ------------------------------------------------------------
# 【执行者】刚被这一发法球命中的生物
# 【产出】放行 -> 给自己挂 zx.os_pass(ball_hit 据此继续分类与结算)
# 【文案】"附加效果对同一个生物 8 秒内最多触发一次。"
# 【为什么记在生物身上】文案明写"同一个生物" —— 记在玩家身上挡不住"换一只接着打"
#   (同构先例: 重溟 passive_gate 的 zx.db_pd / 余烬 zx.em_gate)。
# 【记录方式】zx.os_pd = 该生物"下次可以触发"的 #now 时刻 = 现在 + 160 刻(= 8 秒)。
# 【★ 先 add 0 ★】计分项"没分数"时 `if score` 判**不成立**, 不能靠"没分数"表示
#   "从没触发过"(那样第一次永远触发不了) —— 重溟/余烬都踩过同一个坑。
# ============================================================

scoreboard players add @s zx.os_pd 0
execute if score @s zx.os_pd > #now manacore.meta run return 0
scoreboard players operation @s zx.os_pd = #now manacore.meta
scoreboard players add @s zx.os_pd 160
tag @s add zx.os_pass
