# ============================================================
# sweetdream:internal/damage/deal —— 真正把这一下打出去(宏 {num_str,type,u0..u3})
# ------------------------------------------------------------
# 【执行者】被打的那一只   【从哪来】internal/damage/one 调它
# 【为什么单独拆出来】"天穹·升痕"要在打之前把伤害值乘上去, 而宏参数在**调用那一刻**
#   就固定了 —— 所以必须"先把 zx:work a.num_str 改好, 再调这个宏"。拆出来之后,
#   one 就能在中间插一段"改数值"的逻辑(stg_mul)。
# 【有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来】
# ============================================================

# ①.5 空枕(头盔, 2026-10-17 批 14 补技能): 「造成伤害的时刻」与「静息兑现」都挂这里
#     ★ 为什么不等进度: 「造成伤害」要覆盖近战/弩/法球/技能真伤**全部来源**,
#       而进度只覆盖原版事件那几种。deal 是所有本包伤害的必经之路, 一处全覆盖。
#     ★ 受害者标签 zx.ep_vic 用完即摘(下一行), 不会留到下一次伤害。
#     ★ 选不到攻击者(@a 里没有这个 UUID) = 无归属伤害, 三行都不成立, 自然跳过。
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run tag @s add zx.ep_vic
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/armor/empty_pillow/on_deal
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run tag @s remove zx.ep_vic

$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run damage @s $(num_str) $(type) by @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1]
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run damage @s $(num_str) $(type)
