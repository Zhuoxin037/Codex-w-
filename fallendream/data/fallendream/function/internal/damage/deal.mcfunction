# ============================================================
# fallendream:internal/damage/deal —— 真正把这一下打出去(宏 {num_str,type,u0..u3})
# ------------------------------------------------------------
# 【执行者】被打的那一只   【从哪来】internal/damage/one 调它
# 【为什么单独拆出来】"天穹·升痕"要在打之前把伤害值乘上去, 而宏参数在**调用那一刻**
#   就固定了 —— 所以必须"先把 zx:work a.num_str 改好, 再调这个宏"。拆出来之后,
#   one 就能在中间插一段"改数值"的逻辑(stg_mul)。
# 【有攻击者就带 by; 选不到人(离线)就退化成无归属, 照样打得出来】
# ============================================================

# ①.4 ★★ 2026-10-20 第四次卡顿修复: 归属反查改用**计分项** ★★
#   原来这一整段有 7 处 `@a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]}]`。
#   spark 实测一次玩家 NBT 序列化 ≈ 10 ms(原因见 internal/damage/who 头注释),
#   7 处 ⇒ **每次命中 70 ms 顿帧** —— 就是玩家报的"打到生物卡一下"。
#   现在: 先把 4 个 int 拷进 zx:work who, 由 who 用 manacore.u0..u3 比计算出
#   zx.d_by 标签, 后面全部只认这个标签（零 NBT）。
#   ★ 为什么单独拷一份到 who: 不改 zx:work a（它在中途会被 stg_mul/vuln_tag
#     就地改写, 而 deal 的宏参数 $(u0).. 在调用那一刻就已经固化了, 两者互不影响）。
#   ★ 拷的是整份 a（含 num_str/type）, who 只读 u0..u3, 多余的键它不管。
#   ★ 先 data remove: 万一 a 不存在（理论上不会, one 一定先复原过）, 留着上一
#     次伤害的 who 会把归属错记到上一个人头上 —— 摘干净宁可变"无归属"。
data remove storage zx:work who
data modify storage zx:work who set from storage zx:work a
function fallendream:internal/damage/who
# 同一时刻应独立结算的追加技能伤害：逻辑类型仍为 skill，只有原版投递类型绕过受伤冷却。
$execute if data storage zx:work a{uncapped:1b,type:"fallendream:skill"} unless entity @a[tag=zx.d_by] run return run execute store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) fallendream:parallel_skill
$execute if data storage zx:work a{uncapped:1b,type:"fallendream:skill"} if entity @a[tag=zx.d_by] run return run execute store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) fallendream:parallel_skill by @a[tag=zx.d_by,limit=1]
$execute if data storage zx:work a{uncapped:1b,type:"fallendream:true_damage"} unless entity @a[tag=zx.d_by] run return run execute store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) fallendream:parallel_true_damage
$execute if data storage zx:work a{uncapped:1b,type:"fallendream:true_damage"} if entity @a[tag=zx.d_by] run return run execute store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) fallendream:parallel_true_damage by @a[tag=zx.d_by,limit=1]
$execute unless entity @a[tag=zx.d_by] run return run execute store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) $(type)
$execute if entity @a[tag=zx.d_by] store success storage zx:work hit_success_stack[-1].result.ok byte 1 run damage @s $(num_str) $(type) by @a[tag=zx.d_by,limit=1]
