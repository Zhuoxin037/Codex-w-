# ============================================================
# fallendream:equipment/armor/tread_ash/field_own —— 超限·踏灰: 自己走回灰痕的收益
# ------------------------------------------------------------
# 【谁调用它】tread_ash/field_tick ⑥（条件已判: 主人中途离开过 + 现在又站在灰痕上）
# 【执行者】**主人玩家**（field_tick 用 `as @a[tag=zx.ub,limit=1]` 切过来）
# 【文案(lore 逐字)】…自身离开后再次走入时，额外恢复 8% 最大生命值，并获得 6 秒迅捷Ⅱ。
# 【★ 8% 是"额外" ★】reward 那次位移已经给过 12%（超限），这里是另算一笔 8%。
#   读原版属性 `max_health` 取整，口径与 reward 的 lib/heal 同源。
# ============================================================

execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #ta_fp zx.meta 8
scoreboard players operation #heal_pt zx.meta *= #ta_fp zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
function fallendream:lib/heal

# 6 秒迅捷Ⅱ（amplifier 1 = Ⅱ）
effect give @s minecraft:speed 6 1 true
execute at @s run particle minecraft:end_rod ~ ~0.4 ~ 0.4 0.4 0.4 0.01 8 normal
