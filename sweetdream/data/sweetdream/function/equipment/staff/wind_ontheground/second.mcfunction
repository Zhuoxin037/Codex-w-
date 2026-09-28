# ============================================================
# sweetdream:equipment/staff/wind_ontheground/second —— 每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上
# 【做什么】两件事, 都用 @a[scores={...}] 筛人, 没触发过的人完全不参与:
#   · zx.wg_aura  > 0 —— 正在"风声回响"的 20 秒里, 每 4 秒撕一次
#   · zx.wg_burst > 0 —— 正在"3 轮爆发"里, 打这一轮(每秒一轮)
# 【★ 必须写 at @s ★】只写 execute as 只换了"执行者", **位置/维度还是调用者的**
#   —— 而这里调用者是服务器(#manacore:event/second), 它的位置是世界出生点!
#   少了 at @s 的话, 回响里那些 distance=..5 的选择器就是"以出生点为圆心"在找怪,
#   你身边一只都选不到 -> 有粒子有音效、就是一点伤害都没有。(踩过一次)
# 【顺序很重要: 回响在前, 爆发在后】burst_self 的最后一轮会"点火"起回响
#   (设 zx.wg_aura=20)。如果爆发先跑, 同一 tick 紧接着就会执行回响那一行 ——
#   第 3 轮和回响第 1 跳落在同一刻, 撞上生物的受伤无敌帧, 白白丢一下。
#   把回响放前面, 点火那一 tick 的回响已经跑过了, 第一跳自然推到下一秒。
# ============================================================

# 【备份公共输入口】风声回响的每次结算都要读魔力面板(会写 manacore:in arg),
#   理由见 lib/in_bak
function sweetdream:lib/in_bak

execute as @a[scores={zx.wg_aura=1..}] at @s run function sweetdream:equipment/staff/wind_ontheground/aura_self
execute as @a[scores={zx.wg_burst=1..}] at @s run function sweetdream:equipment/staff/wind_ontheground/burst_self

function sweetdream:lib/in_restore
