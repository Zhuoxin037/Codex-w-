# ============================================================
# sweetdream:equipment/axe/ballad/ol_note_line —— 「音符」路径采样(自递归)
# ------------------------------------------------------------
# 【执行上下文】位置 = 当前采样点; 朝向 = 指向终点(由 ol_note_go 的 facing 定好)
# 【做什么】给当前点 1.3 格内的生物挂 zx.nt_hit, 然后沿朝向前进 1.5 格递归。
# 【★ 上限 12 步 = 18 格 ★】X 最大 8(音符的锁定范围), 18 格绰绰有余;
#   同时它是"起点=终点(两点重合)"时的死循环保险。
# 【★ 递归行不能带 `at @s` ★】at @s 会把位置打回 marker 脚下(终点),
#   采样点永远停在终点 —— 变成"在终点挂 12 次标签"。
# 【★ 到终点就停 ★】@s 是音符 marker, distance 从当前采样点算到它;
#   进了 1.0 格就说明已经走到"该生物原先的位置"。
# ============================================================

execute if entity @s[distance=..1.0] run return 0
execute if score #nt_step zx.meta matches 12.. run return 0
tag @e[type=!#sweetdream:no_damage,distance=..1.3] add zx.nt_hit
scoreboard players add #nt_step zx.meta 1
execute positioned ^ ^ ^1.5 run function sweetdream:equipment/axe/ballad/ol_note_line
