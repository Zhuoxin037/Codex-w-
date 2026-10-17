# ============================================================
# sweetdream:equipment/staff/other_shore/roll_yuanhai —— 25% 概率给「只有噬心」者补「渊海」
# ------------------------------------------------------------
# 【执行者】只有「噬心」的那只生物   【位置】它自己
# 【技能原文】"若其只附有其中一种，则有 25% 的概率使其附加另一种。"
# 【★ 与 roll_shixin 是一对 ★】两份分开写而不是做成一个宏, 是为了避免
#   "宏参数里塞中文/状态名"带来的可读性问题 —— 两个文件各 4 行, 一眼能对上文案。
# ============================================================

function sweetdream:lib/rnd
scoreboard players operation #os_r zx.meta = #rnd zx.meta
scoreboard players operation #os_r zx.meta %= #4 zx.meta
execute if score #os_r zx.meta matches 0 run function sweetdream:tag/mark {target:"@s",mark:"yuanhai"}
