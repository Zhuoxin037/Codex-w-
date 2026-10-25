# ============================================================
# sweetdream:equipment/axe/frost_carve/ol_wing_tick —— 「披霜」每秒 -1 秒
# ------------------------------------------------------------
# 【谁调用它】lib/second: `as @a[scores={zx.frc_ft=1..}]`
# 【执行者】带着「披霜」的玩家
# 【归零做什么】把层数清 0(文案: 3 层持续 12 秒 —— 时长到了层数一起没)
# 【★ 为什么不写 `zx.frc_ft=0..`】选择器只在"分数存在且落在区间"时命中;
#   没分数的玩家天然不进来, 不需要每刻给所有人补 0(那才是热路径开销)。
# ============================================================

scoreboard players remove @s zx.frc_ft 1
execute if score @s zx.frc_ft matches ..0 run scoreboard players set @s zx.frc_fr 0
