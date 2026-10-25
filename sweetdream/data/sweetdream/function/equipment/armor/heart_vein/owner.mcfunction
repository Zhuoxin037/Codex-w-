# ============================================================
# sweetdream:equipment/armor/heart_vein/owner —— 把"泵动归属玩家"从分数搬进 storage
# ------------------------------------------------------------
# 【执行者】带「泵动」的那只生物
# 【为什么 UUID 存成 4 个计分项而不是 NBT】
#   ① 反查玩家要 4 个 int 去比 manacore.u0..u3（lib/u_by / with_from 都要它）;
#   ② 记在**生物自己的分数**上, 逐刻泵动伤害才拿得到归属;
#   ③ 全程整数读写, **零 NBT 序列化**（卡顿坑 1: 玩家整份 NBT ≈10 ms/次）。
# 【出参】zx:work hv.u0..u3
# ============================================================

execute store result storage zx:work hv.u0 int 1 run scoreboard players get @s zx.hv_u0
execute store result storage zx:work hv.u1 int 1 run scoreboard players get @s zx.hv_u1
execute store result storage zx:work hv.u2 int 1 run scoreboard players get @s zx.hv_u2
execute store result storage zx:work hv.u3 int 1 run scoreboard players get @s zx.hv_u3
