# ============================================================
# sweetdream:equipment/armor/late_dusk/shield —— 累计 3 层「回光」⇒ 抗性提升Ⅴ
# ------------------------------------------------------------
# 【执行者】玩家(@s)
# 【★ 文案(逐字) ★】"累计消耗 3 层「回光」后获得 15 秒抗性提升Ⅴ，
#   若受到伤害则立即清除抗性提升。"
# 【★ Ⅴ = amplifier 4 ★】原版等级从 Ⅰ 起算（amp 0）, 所以 Ⅴ 写 4。
# 【★ 受伤即清 ★】zx.ld_r5 记到期时刻, 受击侧看到它 ≥1 就 `effect clear resistance`
#   并把标记清零（见 internal/damage/one 的迟暮段）。用标记而不是"无条件清",
#   是为了不误伤别的来源给玩家的抗性。
# ============================================================

# ① 抗性提升Ⅴ 15 秒
effect give @s minecraft:resistance 15 4 true

# ② 记账：到期时刻（供 second 收尾 / 受击侧判断"这个抗性是不是我们给的"）
scoreboard players operation @s zx.ld_r5 = #now manacore.meta
scoreboard players add @s zx.ld_r5 300

# ③ 累计计数归零，下次重新数 3 层
scoreboard players set @s zx.ld_c 0

# ④ 表现
particle minecraft:dust{color:[0.75,0.65,0.95],scale:1.6} ~ ~1.2 ~ 0.5 0.6 0.5 0.03 24
playsound minecraft:item.totem.use player @s ~ ~ ~ 0.4 1.6
