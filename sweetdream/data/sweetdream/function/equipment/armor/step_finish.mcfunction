# ============================================================
# sweetdream:equipment/armor/step_finish —— 检测窗口到期：兑现或清场
# ------------------------------------------------------------
# 【谁调用它】lib/step ②（zx.sm_t 减到 0）
# 【执行者】玩家
# 【两条出口】
#   zx.sm_done = 1 → 真的位移过：用**最终终点**（lib/step 每刻刷新）兑现两件靴子
#   zx.sm_done = 0 → 原地放技能：什么都不给，只清标签/计时/记录
# 【★ 记录一定要删 ★】否则每放一次技能就在 zx:step casts 里留一份，长期累积，
#   而且这些残留记录会被下一次读到（把冷却减到早已结束的技能上）。
# 【★ 顺序：先兑现、后删记录 ★】雨迹的 sow 只读计分项与 marker，不读记录；
#   踏灰的 reward 要 step_load 读记录（拿"本次位移技能"的 id）—— 所以删记录必须最后。
# ============================================================

# ① 有位移 → 兑现
execute if score @s zx.sm_done matches 1 run function sweetdream:equipment/armor/tread_ash/reward
execute if score @s zx.sm_done matches 1 run function sweetdream:equipment/armor/rain_trace/sow

# ② 清状态
scoreboard players set @s zx.sm_done 0
scoreboard players set @s zx.sm_t 0
tag @s remove zx.sm_chk

# ③ 删掉这次施放的记录（必须在兑现之后：踏灰要读 skill id）
data modify storage zx:step ctx set value {}
data modify storage zx:step ctx.u0 set from entity @s UUID[0]
data modify storage zx:step ctx.u1 set from entity @s UUID[1]
data modify storage zx:step ctx.u2 set from entity @s UUID[2]
data modify storage zx:step ctx.u3 set from entity @s UUID[3]
function sweetdream:equipment/armor/step_forget with storage zx:step ctx
