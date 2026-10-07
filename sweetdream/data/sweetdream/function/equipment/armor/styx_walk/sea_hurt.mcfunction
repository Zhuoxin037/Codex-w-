# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_hurt —— 暗海每秒伤害: 反查释放者
# ------------------------------------------------------------
# 【宏参数】u0..u3 —— 释放者 UUID 的四个 32 位 int(由调用处 with storage zx:work sea 绑定)
# 【为什么用宏】UUID 文本没法写进选择器, 四个 int 可以 —— 和朽木 wood_set、
#   internal/damage/deal 的归属反查同款手法。
# 【反查不到(释放者离线)】execute 选 0 人 → sea_hurt_go 不跑, 这一秒的伤害静默跳过。
#   暗海只有 5 秒寿命, 可接受。
# ============================================================

$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/armor/styx_walk/sea_hurt_go
