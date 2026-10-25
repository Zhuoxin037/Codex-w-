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

# ③ ★ 超限·引雷针: 本次闪电**额外附加**相当于自身最大魔力值 ×0.1 的伤害 ★
#   (2026-10-23 批 K9) —— 原版闪电那 5 点是原版打的、没有归属, 附伤只能自己补一刀。
#   ★ 为什么选 `distance=..3`: 落点在**目标脚下**(skill 用 `at @e[tag=zx.tr_t]` 摆位),
#     而原版闪电的判定半径也是 3 格 ⇒ 口径对齐, 不会出现"看见雷光但没人掉血"。
#     (普攻那道雷是另一回事: 法球停在离怪 1.4 格、到**脚底**约 2.2 格, 选不到人 ——
#      2026-10-13 那次静默失效就是因为用了 distance=..2, 详见 bolt_atk 头注。)
execute if score @s zx.tr_ol matches 1 run function sweetdream:equipment/staff/thunderrod/ol_bolt

# ④ 数"这只生物 5 秒内被劈了几次"(超限机制: 满 3 次 ⇒ 主人下次技能多放一次主动)
#   ★ 先清临时标签再打: 本刻之前残留的 zx.tr_h3 不能算进来(坑: 临时标签要主动撤)。
tag @e[tag=zx.tr_h3,distance=0..] remove zx.tr_h3
execute at @s as @e[type=!#sweetdream:no_damage,distance=..3] run function sweetdream:equipment/staff/thunderrod/bolt_cnt
execute if score @s zx.tr_ol matches 1 if entity @e[tag=zx.tr_h3,distance=..3,limit=1] run function sweetdream:equipment/staff/thunderrod/ol_bonus
tag @e[tag=zx.tr_h3,distance=0..] remove zx.tr_h3

particle minecraft:electric_spark ~ ~1.0 ~ 0.5 0.8 0.5 0.05 24 normal
playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.7 1.3
