# ============================================================
# fallendream:example/use_damage —— 示例: 数值变伤害 + 顺带上效果
# ------------------------------------------------------------
# 【用法】/function fallendream:example/use_damage
#   (建议以玩家身份执行, 这样 @s 才是你; 从控制台跑请把 from 改成 @p)
# 【演示四件事】
#   ① 用固定数值打伤害
#   ② 直接把 manacore 算出来的伤害打出去(read 开关)
#   ③ 用 /effect 的方式造成瞬时伤害
#   ④ 给目标挂一个 buff/debuff
# 【排除表】#fallendream:no_damage 里放了盔甲架、雪球、鸡蛋、经验球这类不该
#   挨打的东西, 选择器里用 type=!#fallendream:no_damage 排除掉。
# ============================================================

# ① 固定数值
data modify storage zx:in arg set value {target:"@e[type=!#fallendream:no_damage,distance=..4]",damage:5.0}
function fallendream:api/damage

# ② 用 manacore 算好的伤害(需要先有人在 manacore 里跑过一次算伤害)
data modify storage zx:in arg set value {target:"@e[type=!#fallendream:no_damage,distance=..4]",read:"manacore"}
function fallendream:api/damage
tellraw @s [{"text":"本次用的伤害: ","color":"gray"},{"nbt":"r.damage","storage":"fallendream:out","color":"gold"}]

# ③ 用瞬时伤害效果造成伤害
data modify storage zx:in arg set value {target:"@e[type=!#fallendream:no_damage,distance=..4]",effect:"minecraft:instant_damage",duration:1,amplifier:0}
function fallendream:api/effect

# ④ 挂一个 10 秒发光
data modify storage zx:in arg set value {target:"@e[type=!#fallendream:no_damage,distance=..4]",effect:"minecraft:glowing",duration:10,amplifier:0}
function fallendream:api/effect
