# ============================================================
# sweetdream:equipment/staff/thunderrod/pend_go —— 预约的那一道雷到期了(宏)
# ------------------------------------------------------------
# 【谁调用它】core/tick: 三维度各一遍, 判 `zx.tr_due <= #now` 才进来
#   (与 tool/thunder/pend_go 同一形态)
# 【宏参数】marker 自己的 data.zx.tr {u0,u1,u2,u3}
# 【执行者】marker, 位置 = 命中点(雷就劈在这儿)
# 【★ 为什么要 `at @s as 主人` ★】伤害要按**主人**的当前魔力与归属来算
#   (api/damage 会取 @s 的 UUID 当 by), 但雷必须落在 **marker 的位置**。
#   `at @s` 先钉住位置/维度, `as` 只换执行者 —— 位置保持在 marker 处。
#   ★ 顺序反了(`as` 在前)位置会跟到主人身上, 雷就劈错地方了。
# ============================================================

# ① 落雷(以主人为执行者算伤害, 位置留在命中点)
$execute at @s as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/staff/thunderrod/bolt_atk

# ② 撤掉自己(一次性 marker, 不摘的话会每刻重复触发)
kill @s
