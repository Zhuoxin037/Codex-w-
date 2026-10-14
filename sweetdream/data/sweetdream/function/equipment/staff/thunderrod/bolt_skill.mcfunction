# ============================================================
# sweetdream:equipment/staff/thunderrod/bolt_skill —— 主动技能的一记雷(只降雷)
# ------------------------------------------------------------
# 【执行者】主人(玩家), 位置 = 某一个被选中的目标脚下(由 skill 的
#   `at @e[tag=zx.tr_t]` 逐个摆好 —— 只改位置不改执行者)
# 【★ 2026-10-13 起: **只降雷**, 不再有"当前魔力 ×0.05"的伤害 ★】
#   与 bolt_atk 同一决定(数值会超模, 用户拍板砍掉), 详见 bolt_atk 头注。
# 【现在这一发是什么】一道真闪电(原版固有伤害 + 着火) + 触发跨武器闪电增益。
# 【★ 必须调 lib/on_lightning ★】跨武器的"自身召唤闪电时…"效果挂在上面
#   (超限·负离子的 8 秒落点伤害等)。2026-10-13 漏接事故见 bolt_atk 头注。
# ============================================================

summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_own"]}

# ★ "自身召唤闪电"的公共收尾钩子 ★(@s = 主人 / 位置 = 落点)
function sweetdream:lib/on_lightning

particle minecraft:electric_spark ~ ~1.0 ~ 0.5 0.8 0.5 0.05 24 normal
playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.7 1.3
