# ============================================================
# sweetdream:equipment/staff/thunderrod/ol_bonus —— 超限·引雷针: 给主人上「下次技能多放一次」增益
# ------------------------------------------------------------
# 【谁调用它】bolt_skill 第 ④ 步(已确认这批里有生物 5 秒内被劈满 3 次)
# 【执行者】主人(玩家)
# 【文案】"之后在 5 秒内若有生物被闪电命中 3 次, 则自身**下一次使用技能**时会额外
#   附加一次本技能的主动技能, 该增益持续 **12 秒**。"
# 【★ 增益为什么记在**主人**身上 ★】bolt_skill 的执行者就是主人(排队 marker 用
#   `as @a[nbt={UUID:...}]` 换回来的), 直接 @s 落分最稳 —— 不用再去反查 uuid。
# 【★ 到期刻而不是倒计时 ★】与全仓"用 `#now + N` 的到期刻"一致: 每秒减一的倒计时
#   要挂一个每刻驱动, 而到期刻只在"用的时候"比一下, 没有常驻开销。
#   ⇒ zx.tr_bonus = 1(有增益) + zx.tr_bdue = 到期刻; 用的时候判 `due > #now`,
#     过期就当没有(顺手清掉)。
# ============================================================

scoreboard players set @s zx.tr_bonus 1
scoreboard players operation @s zx.tr_bdue = #now manacore.meta
scoreboard players add @s zx.tr_bdue 240

tellraw @s [{"text":"「引雷针」—— 5 秒内有生物被闪电命中 3 次，下次技能将额外再放一次主动（12 秒内有效）","color":"aqua"}]
execute at @s run particle minecraft:electric_spark ~ ~1.2 ~ 0.6 0.8 0.6 0.05 24 normal
