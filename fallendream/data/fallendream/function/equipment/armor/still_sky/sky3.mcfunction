# ============================================================
# fallendream:equipment/armor/still_sky/sky3 —— 8 秒内三层齐: 抗性Ⅴ + 移速 +40%
# ------------------------------------------------------------
# 【执行者】玩家
# 【口径】"移动速度 +40%" 用原版 speed Ⅱ(每级 +20%) 直接表达 —— 与本件其它
#   移速来源同为同一个属性, 且自带到期, 不需要额外的 modifier 清账。
# 【★ 触发后把计数与窗口一起清掉 ★】不清窗口的话, 8 秒内第四层会立刻再触发一次。
# ============================================================
scoreboard players set @s zx.s2_sky_ct 0
scoreboard players set @s zx.s2_sky_cw 0
effect give @s minecraft:resistance 4 4 true
effect give @s minecraft:speed 4 1 true
playsound minecraft:block.beacon.activate player @s ~ ~ ~ 0.7 1.5
