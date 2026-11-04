# ============================================================
# sweetdream:equipment/staff/surge_ebb/hit —— 潮涌，潮枯：法球命中回调（被动）
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit ⑥ 的 `function $(hit)`（★ 不是进度 ★）
# 【执行者】法球本体    【宏参数】球的数据 {uuid,dmg,style,u0..u3,hit}
# 【文案】每次普攻命中生物后，若自身当前术阵未满，则召唤一个持续 4 秒的术阵；
#   若已满，则使全部"追随者"的持续时间 +1 秒。
# 【★ 2026-11-01 改走 ball.hit 回调 ★】同 lucid_illusion/hit：
#   法球命中不是"平A"，挂 player_hurt_entity + atk_charge 满蓄力闸门的结果是
#   永远不成立；既有法杖一律用球的 data.hit 回调。
# ============================================================

# ① 这次命中真的打到生物了吗
execute unless entity @e[tag=zx.ball_hit,distance=0..4,limit=1] run return 0

# ② 反查施法者
data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb

# ③ 施法者结算术阵（未满就召 4 秒，满则给追随者 +1 秒）
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/surge_ebb/passive
tag @a remove zx.mc_by
