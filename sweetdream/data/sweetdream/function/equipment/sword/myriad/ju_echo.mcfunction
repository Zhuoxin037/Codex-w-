# ============================================================
# sweetdream:equipment/sword/myriad/ju_echo —— 居合期间切换形态: 追加一次真实伤害
# ------------------------------------------------------------
# 【执行者】玩家   【前置】
#   · #mq_echo = 本次技能**单次**伤害(整数, 由调用方从 manacore:out r.damage 取)
#   · zx.mq_dmg 标签 = 本次技能实际打到的生物
# 【文案】「居合」状态下每切换一次【万念】或【千散】都会对造成了伤害的生物
#         再次造成一次相等的真实伤害。
# 【★ "造成了伤害的生物" = 本次这批 ★】不是全场、也不是"上一次" —— 就是
#   这一发技能真正打中的那些(由调用方在打之前用 zx.mq_dmg 钉好)。
# 【★ 真实伤害 = sweetdream:true_damage ★】无视护甲, 本包自己注册的伤害类型。
# 【★ 相等 = 和这一发的**单次**数值相等 ★】不和"重复 N 次之后的总量"相等 ——
#   文案写的是"再次造成一次…伤害", 一次就是一次。
# ============================================================

execute unless score @s zx.mq_ju matches 1.. run return 0
execute unless score #mq_echo zx.meta matches 1.. run return 0
execute unless entity @e[tag=zx.mq_dmg,limit=1] run return 0

data modify storage zx:in arg set value {target:"@e[tag=zx.mq_dmg]",damage:0.0,type:"sweetdream:true_damage"}
execute store result storage zx:in arg.damage double 1 run scoreboard players get #mq_echo zx.meta
function sweetdream:api/damage

execute at @s run particle minecraft:sweep_attack ~ ~1.1 ~ 1.4 0.7 1.4 0.03 10 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.5 2.0
