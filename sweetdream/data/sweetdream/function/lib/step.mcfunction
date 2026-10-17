# ============================================================
# sweetdream:lib/step —— 「技能施放后有没有真的位移」每刻判据（踏灰 / 雨迹共用）
# ------------------------------------------------------------
# 【谁调用它】core/tick：`execute as @a[tag=zx.sm_chk] at @s run function …`
#   平时没人带这个标签（只有刚放过技能、脚上穿踏灰/雨迹的玩家带 1 秒）⇒ 零开销。
# 【执行者】玩家
# 【判据】与 step_observe 记下的起点坐标比：
#   · 水平任一轴 ≥ 1.5 格（150，单位 0.01）
#   · 竖直 ≥ 2 格（200）—— 只往上跳一下不算位移技能，所以阈值比水平大一档
# 【★ 三个轴都判、但只兑现一次 ★】x/z/y 各两行（正负方向），六条都能调到
#   step_moved；它首行判 `zx.sm_done` —— 第一次确认后置 1，之后都空转。
#
# 【★ 2026-10-17 第二次改：雨迹改成"逐刻就地撒点" ★】
#   用户实测："用无息位移后只有前面大概 3 格有水迹"。旧的"每 5 刻补一段
#   起点→终点插值"有三个不可控点：① 段的终点是"当刻位置"，玩家在段内掉头
#   （无息是去 8 格再闪回）时插值会横穿场地甚至回到起点附近，整段糊成一团；
#   ② 撒点被推迟到"够 5 刻"才发生，用户完全看不出到底成没成；
#   ③ 任何一次门控失败/节流错位都会静默漏掉一整段。
#   现在改成：**每刻**判"离上一个水迹点够不够远"（0.45 格），够远就当场在脚下
#   撒一个点（rain_trace/sow）。轨迹由玩家自己走出来 —— 去程、回程、绕圈、
#   撞墙停下，怎么走都是对的；水迹也是**边走边出现**，一眼能看出成没成。
#   代价是点数变多（无息全程约 20 个），但每个点只是一个小 display 实体，
#   5 秒后自毁，实测无压力。
# ============================================================

# ① 雨迹：确认位移后每刻判一次"该不该撒点"（sow 内部含穿着门控与距离判据）
#   ★ 放在 ③④⑤ 判据之前：本刻确认了位移，下一刻就撒第一点（step_moved 里还会
#     立刻补一次，起手不延迟）★
execute if score @s zx.sm_done matches 1 run function sweetdream:equipment/armor/rain_trace/sow

# ② 窗口倒计时：到点 → step_finish（有位移就兑现，没有就只清场）
scoreboard players remove @s zx.sm_t 1
execute if score @s zx.sm_t matches ..0 run function sweetdream:equipment/armor/step_finish
#   ★ 收场后必须立刻 return：step_finish 已经把标签摘了，但本函数后面还会继续跑，
#     万一玩家这一刻正好又超出阈值，会把 sm_done 重新置 1（残留到下一次施法）。
execute if score @s zx.sm_t matches ..0 run return 0

# ③ 水平 X
execute store result score #sm_cx zx.meta run data get entity @s Pos[0] 100
scoreboard players operation #sm_d zx.meta = #sm_cx zx.meta
scoreboard players operation #sm_d zx.meta -= @s zx.sm_x
execute if score #sm_d zx.meta matches 150.. run function sweetdream:equipment/armor/step_moved
execute if score #sm_d zx.meta matches ..-150 run function sweetdream:equipment/armor/step_moved

# ④ 水平 Z
execute store result score #sm_cz zx.meta run data get entity @s Pos[2] 100
scoreboard players operation #sm_dz zx.meta = #sm_cz zx.meta
scoreboard players operation #sm_dz zx.meta -= @s zx.sm_z
execute if score #sm_dz zx.meta matches 150.. run function sweetdream:equipment/armor/step_moved
execute if score #sm_dz zx.meta matches ..-150 run function sweetdream:equipment/armor/step_moved

# ⑤ 竖直 Y（阈值 200 = 2 格）
execute store result score #sm_cy zx.meta run data get entity @s Pos[1] 100
scoreboard players operation #sm_dy zx.meta = #sm_cy zx.meta
scoreboard players operation #sm_dy zx.meta -= @s zx.sm_y
execute if score #sm_dy zx.meta matches 200.. run function sweetdream:equipment/armor/step_moved
execute if score #sm_dy zx.meta matches ..-200 run function sweetdream:equipment/armor/step_moved
