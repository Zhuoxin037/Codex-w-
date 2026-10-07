# ============================================================
# sweetdream:internal/damage/deal —— 真正把这一下打出去(宏 {num_str,type,u0..u3})
# ------------------------------------------------------------
# 【执行者】被打的那一只   【从哪来】internal/damage/one 调它
# 【为什么单独拆出来】"天穹·升痕"要在打之前把伤害值乘上去, 而宏参数在**调用那一刻**
#   就固定了 —— 所以必须"先把 zx:work a.num_str 改好, 再调这个宏"。拆出来之后,
#   one 就能在中间插一段"改数值"的逻辑(stg_mul)。
# 【有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来】
# ============================================================

$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run damage @s $(num_str) $(type) by @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1]
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run damage @s $(num_str) $(type)
