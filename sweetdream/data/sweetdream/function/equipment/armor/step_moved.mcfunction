# ============================================================
# sweetdream:equipment/armor/step_moved —— 位移已确认（只标记，不兑现）
# ------------------------------------------------------------
# 【谁调用它】lib/step ③④⑤（六个轴方向判据里任一成立）
# 【执行者】玩家
# 【★ 为什么这里不兑现踏灰 ★】踏灰的"回血 + 减冷却"要等位移**走完**才知道
#   "这次位移是哪个技能"（记录在 zx:step，step_finish 才删）—— 所以这里只置
#   zx.sm_done=1，兑现统一放到窗口末尾的 step_finish。
# 【★ 雨迹为什么在这里就撒起点 ★】旧版等窗口结束才撒，用户看不出成没成。
#   现在确认位移的这一刻：① 在施法刻留的锚点 marker 上撒"起点那一摊"；
#   ② 把上一个水迹点=施法起点；③ 顺手走一次间距判据（跨过 1.3 格就再补一点）
#   ⇒ 水迹跟着人走，边走边出现。
# 【★ 去重靠 zx.sm_done ★】同一刻 x 与 z 都超阈值会连调两次，第二次见到
#   done=1 直接返回。也别在这里清标签 —— 窗口还要继续跑。
# ============================================================

execute if score @s zx.sm_done matches 1 run return 0
scoreboard players set @s zx.sm_done 1

# ① 先把旧的"上一滴"标签摘掉 —— 这样 ③ 才判得出"起点到底撒没撒成"
tag @e[tag=zx.rt_last,distance=0..] remove zx.rt_last

# ② 起点那一摊：撒在**施法刻的锚点 marker** 上，不是玩家当前位置。
#   ★ 2026-10-18：此刻玩家已经挪出去了（判据就要求 1.5 格），用 `at @s` 撒会把
#     起手那一段漏掉。
#   ★ 距离从 `..3` 放宽到 `..16`：影刃 / 沉锚这类一步跨 3 格以上的位移，确认位移
#     那一刻玩家早已跳出 3 格外 ⇒ 锚点永远找不到 ⇒ 起点那摊从来不撒
#     （用户报的"影刃是前面一段没有"）。
execute at @e[tag=zx.rt_anchor,distance=..16,limit=1] run function sweetdream:equipment/armor/rain_trace/sow_now

# ③ 锚点丢了（超出 16 格 / 被 step_observe 的清理误删）→ 退化成"就地撒一个"，
#    至少别让起手完全空着。判据是"上一滴标签还在不在"——② 撒成了 dot_spawn 就会建锚。
execute unless entity @e[tag=zx.rt_last,distance=0..,limit=1] run function sweetdream:equipment/armor/rain_trace/sow_now

# ④ 锚点用完即清（放在 ②③ 之后：② 可能还没用到它）
#    distance=..32 而不是 ..3：影刃一步跳出去后，锚点离玩家已经十几格了。
kill @e[tag=zx.rt_anchor,distance=..32]

# ⑤ 立刻把"起点 → 现在"这段按 1.4 格铺满（不再手写"距离够不够一个板宽"，
#    距离判据与补点全在 fill 里；起手因此没有延迟）。
#    ★ zx.rt_lx/ly/lz 不用在这里赋值 —— dot_spawn 每生成一滴就会把它同步成
#      那一滴的真实坐标，比"拿施法起点顶一下"更准（也少一处会忘的赋值）。
function sweetdream:equipment/armor/rain_trace/sow
