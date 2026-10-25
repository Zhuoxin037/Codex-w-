# ============================================================
# sweetdream:equipment/staff/bent_ray/mark_zg —— 给一只生物附加(刷新)「折光」
# ------------------------------------------------------------
# 【谁调用它】ball_hit ①(逐只)   【执行者】**被命中的生物**
# 【入参】#br_ol zx.meta = 发射者手上那件是不是超限·折径(0/1, 由 ball_hit ⓪ 设好)
# 【时长】10 秒 = 200 刻(**用户 2026-10-23 拍板: "全部改为 10 秒吧"**)。
#   沿革: 15 秒(2026-10-17 拍板) -> 10 秒(2026-10-23 改; 与整理稿「折径·每层 10 秒」
#   对齐, 原版与超限**同用 10 秒**)。重复命中**刷新**, 不叠加。
# 【记法】zx.br_gl = 到期绝对刻; 判定一律 `if score @s zx.br_gl > #now`。
#   用绝对刻而不是"每秒 -1": 不需要 lib/second 参与, 也不会被别的系统打断。
# 【★ 层数(2026-10-23 批 K9) ★】zx.br_gn = 身上的「折光」层数(1..3)。
#   原版恒 1(重复命中只刷新时长); 超限**最多 3 层** —— 主动技能会按层数额外射出
#   分光束("每有一层「折光」都会额外…射出光束")。
#   ★ 到顶就不再加层, 但**时长照常刷新**(与"命中就刷新"的既有手感一致)。
# ============================================================

tag @s add zx.br_g

# ① 层数 +1(上限: 原版 1 / 超限 3)
scoreboard players add @s zx.br_gn 0
scoreboard players set #br_cap zx.meta 1
execute if score #br_ol zx.meta matches 1 run scoreboard players set #br_cap zx.meta 3
execute if score @s zx.br_gn < #br_cap zx.meta run scoreboard players add @s zx.br_gn 1

# ② 刷新到期刻
scoreboard players operation @s zx.br_gl = #now manacore.meta
scoreboard players add @s zx.br_gl 200
particle minecraft:end_rod ~ ~1 ~ 0.2 0.3 0.2 0.02 6 normal
