# ============================================================
# sweetdream:equipment/staff/thunderrod/ol_extra —— 超限·引雷针: 增益触发的「额外一次主动」
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑥'' 步(`if score @s zx.tr_bonus matches 1`, 且 zx.tr_t 还在)
# 【执行者】主人(玩家)
# 【文案】"则自身下一次使用技能时会额外附加一次本技能的主动技能"。
#   §5.2 第 11 条(用户答复): 这一次 **无蓝耗、无冷却** —— 所以这里不调 skill/check、
#   不扣魔力、不起冷却, 只把"落雷"这一段照原样再走一遍。
# 【★ 为什么复用 zx.tr_t 而不是重新圈人 ★】文案的"额外附加一次本技能的主动技能"
#   = 同一次主动再放一遍 ⇒ 目标就是刚才那批。重新圈会变成"重新选 7 个", 不是一回事。
# 【★ 三道雷的排队也要再走一遍 ★】否则额外这一次只有一道 ⇒ 与"本技能的主动技能"
#   对不上。排队函数本身不扣蓝不进冷却, 直接复用即可。
# ============================================================

tellraw @s [{"text":"「引雷针」—— 增益触发：额外再放一次主动（本次无蓝耗、无冷却）","color":"aqua"}]
execute at @s run particle minecraft:electric_spark ~ ~1.4 ~ 0.8 1.0 0.8 0.06 32 normal

execute if score @s zx.tr_ol matches 0 at @e[tag=zx.tr_t,distance=0..] run function sweetdream:equipment/staff/thunderrod/bolt_skill
execute if score @s zx.tr_ol matches 1 run function sweetdream:equipment/staff/thunderrod/ol_volley
