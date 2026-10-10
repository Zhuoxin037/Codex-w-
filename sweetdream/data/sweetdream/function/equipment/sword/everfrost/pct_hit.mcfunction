# ============================================================
# sweetdream:equipment/sword/everfrost/pct_hit —— 超限·永霜的"每秒那一下"
# ------------------------------------------------------------
# 【原文】"之后每秒对被冰冻的生物造成一次相当于**其最大生命值 ×0.03**的真实伤害"
# 【★ 口径钉死(用户 2026-10-08 明确要求) ★】
#   每秒这一下的 ×0.03, 基数 = **@s 自己(= 被打的那只生物)的最大生命**,
#   **不是玩家的**。改这里之前先看使用教程「第二十一批 · 批 E2」永霜那条。
# 【★ 关键: 是"那只生物自己的"最大生命, 不是玩家的 ★】
#   manacore 的 health_ratio 用的是**玩家**的最大生命, 这里不能用 ——
#   必须逐只生物读它自己的 max_health 再各自打出去。
# 【执行者】那只生物(由 pulse_ol 用 `as ... at @s` 逐个切过来)
# 【怎么算 ×0.03】attribute get 100 拿到 max_health×100(整数), 再
#   store double 0.0003 => max_health × 100 × 0.0003 = max_health × 0.03。
#   (直接 get 1 会把 25.5 截成 25, 血上限有小数时误差更大, 所以放大 100 倍再缩。)
# 【伤害类型】sweetdream:true_damage(本包注册的, 无视护甲)。
# ============================================================

# ① 这只生物的最大生命 ×0.03
execute store result storage zx:work efp.dmg double 0.0003 run attribute @s minecraft:max_health get 100

# ② 打成真实伤害(每次都 set value 整套, 免得沿用上一次的 type)
data modify storage zx:in arg set value {target:"@s",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage zx:work efp.dmg
function sweetdream:api/damage

# ③ 表现
particle minecraft:snowflake ~ ~1 ~ 0.3 0.5 0.3 0.02 10 normal
