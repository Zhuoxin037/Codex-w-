# ============================================================
# sweetdream:equipment/staff/bent_ray/ol_side_n —— 超限·折径: 按折光层数发 N 道分光束(递归)
# ------------------------------------------------------------
# 【谁调用它】chain ⑧.5(`if score #br_lay matches 1..`)   【执行者】施法者(玩家)
# 【入参】#br_lay zx.meta = 下一棒身上有几层「折光」(1..3); zx.br_next = 下一棒(要排除)
# 【文案】"且每有一层「折光」都会额外对**除主光束锁定的生物以外**离其最近的生物
#   射出光束。(……多层「折光」额外射出的光束**伤害独立计算**)"
# 【★ 为什么递归而不是三条并列 ★】"每有一层" ⇒ 层数 1/2/3 分别射 1/2/3 道;
#   递归深度最多 3, 而且省掉三份复制粘贴(全仓"补点自递归"同一套路)。
#   ★ 每次进来都重新选"最近的" —— 前一道把人打死了的话, 后一道会自然换目标。
# 【★ 伤害独立计算 ★】每道分光束各自跑一次 damage/calc(各自读一次当前魔力/面板),
#   不是"算一次乘 N"; 这是文案"独立计算"的字面要求。
# ============================================================

execute if score #br_lay zx.meta matches ..0 run return 0

function sweetdream:equipment/staff/bent_ray/ol_side

scoreboard players remove #br_lay zx.meta 1
function sweetdream:equipment/staff/bent_ray/ol_side_n
