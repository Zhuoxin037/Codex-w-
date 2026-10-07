# ============================================================
# sweetdream:equipment/sword/myriad/ju_end —— 「居合」结束: 清除剑魂
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】结束后清除“剑魂”。
# 【★ 只清剑魂, 不清居合增伤层数 zx.mq_jb ★】
#   jb 是"下一次技能伤害 +20%", 属于**已经许诺给下一次**的东西 ——
#   居合结束时不该顺手把它没收(下一次技能可能就在同一秒之后)。
#   它由下一次 cast 在真正用掉之后清零(见两把 cast 里的 `set 0`)。
# ============================================================

scoreboard players set @s zx.mq_soul 0
execute at @s run particle minecraft:dust{color:[1.0,0.80,0.45],scale:1.2} ~ ~1 ~ 1.4 0.9 1.4 0.04 24 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.4
tellraw @s [{"text":"「居合」结束，剑魂已散","color":"gray"}]
