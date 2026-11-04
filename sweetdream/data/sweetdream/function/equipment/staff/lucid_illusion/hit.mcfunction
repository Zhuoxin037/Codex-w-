# ============================================================
# sweetdream:equipment/staff/lucid_illusion/hit —— 清醒与幻觉：法球命中回调
# ------------------------------------------------------------
# 【谁调用它】projectile/ball/hit ⑥ 的 `function $(hit)`（★ 不是进度 ★）
# 【执行者】法球本体    【宏参数】球的数据 {uuid,dmg,style,u0..u3,hit}
# 【受害者】本刻临时标签 zx.ball_hit（球心 1.6 立方体）
# 【文案】每次普攻命中生物后额外生成一个法球。若法球数量已到上限，
#   则可以超出限制并生成一个持续 10 秒的法球（最多 3 个）。
# 【★ 2026-11-01 改走 ball.hit 回调 ★】
#   原来挂的是 player_hurt_entity 进度 + lib/atk_charge 满蓄力闸门 —— 两处都不对：
#   ① 法球命中不是"平A"，atk_charge 量的是近战挥砍间隔，法球根本不更新 zx.atk_lt，
#      于是 atk_ok 恒不成立，这个回调一辈子不跑；
#   ② 既有的法杖（wake_bell/begonia/long_night）一律用球的 data.hit 回调，不用进度。
#   现在照既有范式改。普攻节奏由 staff/gate 统一管，这里不需要再判蓄力。
# 【怎么找回施法者】球里存了 u0..u3，用 lib/find_by 反查出玩家 → zx.mc_by 标签。
#   （零 NBT 序列化，与 deal 里的 who 同一套手法）
# ============================================================

# ① 这次命中真的打到生物了吗
execute unless entity @e[tag=zx.ball_hit,distance=0..4,limit=1] run return 0

# ② 反查施法者
data modify storage zx:work fb.u0 set from entity @s data.u0
data modify storage zx:work fb.u1 set from entity @s data.u1
data modify storage zx:work fb.u2 set from entity @s data.u2
data modify storage zx:work fb.u3 set from entity @s data.u3
function sweetdream:lib/find_by with storage zx:work fb

# ③ 施法者生成一个法球（到上限就走 10 秒额外球）
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:equipment/staff/lucid_illusion/orb
tag @a remove zx.mc_by
