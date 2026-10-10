# ============================================================
# sweetdream:equipment/axe/charge/self_hurt —— 第二形态的代价: 攻击反噬自身
# ------------------------------------------------------------
# 【原文】"但每次攻击都会对自身造成相当于自身最大生命值 ×0.05 的伤害。"
# 【谁调用它】hit(每次"攻击到生物"时, 且已进入第二形态)
# 【执行者】玩家(打自己)
# 【怎么算 ×0.05】attribute get 100 拿到 max_health×100(整数), 再
#   store double 0.0005 => max_health × 100 × 0.0005 = max_health × 0.05。
#   (和永霜 pct_hit 同一个放大再缩的写法, 免得血上限带小数时被截断。)
# 【伤害类型】sweetdream:true_damage —— 本包注册的、无视护甲。
#   ★ 它不写"by 谁", 所以不会把自己的击杀记到自己头上(自伤本来也不该记)。
# ============================================================

execute store result storage zx:work chgs.dmg double 0.0005 run attribute @s minecraft:max_health get 100

data modify storage zx:in arg set value {target:"@s",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage zx:work chgs.dmg
function sweetdream:api/damage

execute at @s run particle minecraft:crit ~ ~1 ~ 0.4 0.5 0.4 0.05 8 normal
