# ============================================================
# sweetdream:equipment/axe/charge/second —— 每秒入口(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【★ 必须写 at @s ★】只写 execute as 只换了执行者, 位置还是**服务器**的
#   (也就是世界出生点)。这个技能里所有 distance=..8 / ..1 都要相对玩家算,
#   少了 at @s 会变成"在出生点附近找怪"。(风行回响踩过一模一样的坑)
# 【备份公共输入口】tick 会写 manacore:in arg(读魔力), 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

# ① 被动: 主手持着它 -> 迅捷 I
execute as @a run function sweetdream:equipment/axe/charge/passive

# ①' 兜底: 形态还挂着(chg_mode=1)但状态已经是 0 -> 把第二形态的加成收回去
#    正常路径是 `end -> mode_off`; 这里防的是漏网(end 没跑到 / chg_on 被别处清成 0 /
#    玩家在状态里下线后状态没跑完)。
#    ★ 不会误伤"续上"的那种: end_ol -> autocast 是**同步**把 chg_on 置回 15 的,
#      不存在"chg_mode=1 且 chg_on=0"的中间态。
execute as @a[scores={zx.chg_mode=1,zx.chg_on=0}] at @s run function sweetdream:equipment/axe/charge/mode_off

# ② 超载状态: 每秒续迅捷(基础 II / 超限 III) + 召一次雷 + 倒计时
execute as @a[scores={zx.chg_on=1..}] at @s run function sweetdream:equipment/axe/charge/tick

# ③ ★ 2026-10-10 用户定稿: **删掉"冷却自然走完 -> 自动使用"这条路** ★
#   自动使用**只在状态结束那一拍**由 end -> end_ol 触发, 且要求"状态期间冷却已归零"
#   (= 平A 的 -4 秒被动把冷却压到了 0)。
#   · 状态期间冷却归零了 -> 状态结束那一拍 end_ol 自动再开一轮(重新起冷却 + 新状态), 继续超载;
#   · 没归零 -> 超载就此结束, 冷却恢复自然流动, **不再自动开**(要再放得自己手动按)。
#   ★ 冻结(原文"停止正常冷却缩减")只在**第二形态**(chg_mode=1)的状态期间生效;
#     第一阶段(**第一形态**)的状态不冻, 冷却照常自然 -1/秒 —— 见 tick ③ / freeze_cd。
#   (原先这里每秒对 chg_ol=1 / chg_mode=1 的玩家跑 mode_tick 自动开一轮 —— 那会让
#    "冷却一好就自动开", 与"必须打够把冷却压到 0 才续"的口径相反, 已删。)

function sweetdream:lib/in_restore
