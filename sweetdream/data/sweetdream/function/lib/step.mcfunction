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
#   改为"每刻判一次离上一点够不够远"，就地撒点 —— 轨迹由玩家自己走出来。
#
# 【★ 2026-10-18 第三次改：判据挪进 sow，间距改成"一个板宽" ★】
#   用户又报："水迹依旧没有铺满，且水迹之间还有重叠。"根因是**间隔 = 每刻位移量**
#   而速度在变：去程 0.5 格/刻 ⇒ 板宽 2.2 格下叠 4 层（看着像一坨坨重叠）；
#   回程 2 格、斜向冲刺 2.8 格/刻 ⇒ 间隔比板宽还大（看着"没铺满"）。
#   ⇒ 现在本函数只负责"每刻把判据跑一遍"，具体阈值（1.3 格欧氏距离）、
#     快速位移的补点、起点那一摊，全在 rain_trace/sow 里（见那边的注释）。

# ============================================================

# ① 雨迹：确认位移后每刻跑一次撒点判据（穿着门控 / 间距 / 补点都在 rain_trace/fill 里）
#   ★ 放在 ③④⑤ 判据之前：本刻确认了位移，下一刻就撒点
#   ★ 起点那一摊不在这里 —— step_moved 会用施法刻的锚点 marker 单独补，见那边。
execute if score @s zx.sm_done matches 1 run function sweetdream:equipment/armor/rain_trace/sow

# ============================================================
# ② 窗口续期：**位移还在继续就不倒数**
# ------------------------------------------------------------
# 【★ 2026-10-18：为什么必须有这一段 ★】
#   用户连报四条：横刀（3 格，12 刻）覆盖满；无息（去 8 格 + 归位）"到中间就断了"；
#   影刃"前面一段没有"；沉锚"后面一段没了"。横刀满 = 判据没错，断的全是**长位移**。
#   根因就是这里：窗口写死 24 刻，位移一走超过 24 刻（或叠加了确认延迟），
#   step_finish 就把 zx.sm_chk 摘了 —— lib/step 再也不跑，**后半段一个点都不撒**。
#   ⇒ 判据改成"与上一刻坐标比，挪了 ≥0.1 格就算还在动"：在动 → sm_t 顶回 12，
#     于是窗口只在"真的停下来之后"才开始倒数。
#
# 【为什么要 sm_n 上限】不设上限的话，玩家按住 W 一路狂奔就永远在动 ⇒ 窗口永不结束
#   ⇒ 踏灰永远不回血、雨迹一直铺。所以只在 `sm_done == 1`（已确认是位移技能）之后
#   才续期，且累计续 56 刻（2.8 秒）就停止续期、让窗口自然关门。
#
# 【为什么先读当前坐标到 #sm_cx/cy/cz】下面 ③④⑤ 还要用同一个值，顺手省两次 data get。
# ============================================================
execute store result score #sm_cx zx.meta run data get entity @s Pos[0] 100
execute store result score #sm_cy zx.meta run data get entity @s Pos[1] 100
execute store result score #sm_cz zx.meta run data get entity @s Pos[2] 100

#   与"上一刻"的偏移（x/z 取平方和，y 取差值绝对值化的正负双判）
scoreboard players operation #sm_mx zx.meta = #sm_cx zx.meta
scoreboard players operation #sm_mx zx.meta -= @s zx.sm_px
scoreboard players operation #sm_mz zx.meta = #sm_cz zx.meta
scoreboard players operation #sm_mz zx.meta -= @s zx.sm_pz
scoreboard players operation #sm_my zx.meta = #sm_cy zx.meta
scoreboard players operation #sm_my zx.meta -= @s zx.sm_py
#   ★ 钳位防平方溢出（同 rain_trace/fill）：|d| ≤ 30000 ⇒ 两轴平方和 ≤ 1.8e9 < 2^31
execute if score #sm_mx zx.meta matches 30000.. run scoreboard players set #sm_mx zx.meta 30000
execute if score #sm_mx zx.meta matches ..-30000 run scoreboard players set #sm_mx zx.meta -30000
execute if score #sm_mz zx.meta matches 30000.. run scoreboard players set #sm_mz zx.meta 30000
execute if score #sm_mz zx.meta matches ..-30000 run scoreboard players set #sm_mz zx.meta -30000

scoreboard players operation #sm_m zx.meta = #sm_mx zx.meta
scoreboard players operation #sm_m zx.meta *= #sm_mx zx.meta
scoreboard players operation #sm_mt zx.meta = #sm_mz zx.meta
scoreboard players operation #sm_mt zx.meta *= #sm_mz zx.meta
scoreboard players operation #sm_m zx.meta += #sm_mt zx.meta

#   这一课在不在动？水平 ≥0.1 格（10² = 100）或 竖直 ≥0.1 格（10）
scoreboard players set #sm_mv zx.meta 0
execute if score #sm_m zx.meta matches 100.. run scoreboard players set #sm_mv zx.meta 1
execute if score #sm_my zx.meta matches 10.. run scoreboard players set #sm_mv zx.meta 1
execute if score #sm_my zx.meta matches ..-10 run scoreboard players set #sm_mv zx.meta 1

#   ★ "该不该冻结倒数"用**一个决定量** #sm_hold 表示，不要在递减那一行堆条件 ——
#     同时放着"在动就不减""没确认位移就减""超上限就减"三条会互相重复扣分
#     （第一版就写成三条，结果"没确认位移 + 没在动"那一格每刻被减 2 次，
#      窗口只有 12 刻，1 秒内就收场，踏灰/雨迹全部提前关门）。
scoreboard players set #sm_hold zx.meta 0
execute if score @s zx.sm_done matches 1 if score #sm_mv zx.meta matches 1 if score @s zx.sm_n matches ..56 run scoreboard players set #sm_hold zx.meta 1

#   冻结时顺手把 sm_n 累加、把窗口顶回 12 刻（12 而不是 16：踏灰的"回血 + 减冷却"
#   是在窗口末尾兑现的，位移一停就等 0.6 秒比较跟手；雨迹最后一滴也在这段时间里）
execute if score #sm_hold zx.meta matches 1 run scoreboard players add @s zx.sm_n 1
execute if score #sm_hold zx.meta matches 1 run scoreboard players set @s zx.sm_t 12

#   记账"上一刻坐标"（本轮结束时它就该是本刻的坐标）
scoreboard players operation @s zx.sm_px = #sm_cx zx.meta
scoreboard players operation @s zx.sm_py = #sm_cy zx.meta
scoreboard players operation @s zx.sm_pz = #sm_cz zx.meta

# ============================================================
# ③ 窗口倒数：到点 → step_finish（有位移就兑现，没有就只清场）
#   ★ 只有 #sm_hold = 1 的那几刻不倒数，所以倒数是"停下来之后才开始数"。
# ============================================================
execute unless score #sm_hold zx.meta matches 1 run scoreboard players remove @s zx.sm_t 1
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
