# ============================================================
# sweetdream:equipment/armor/gyre/get —— 回旋：技能消费「渊海」→ 获得「旋步」
# ------------------------------------------------------------
# 【谁调用它】lib/on_consume（技能真消耗了「渊海」之后；src:"skill" 已在那层过滤）
# 【执行者】消耗者（= 那个玩家）
# 【技能原文（lore 逐字）】
#   "自身魔力值上限 +140。自身技能成功消费一个生物的「渊海」后，为自身获得持续 6 秒
#    的「旋步」。该效果 12 秒内最多触发一次。"
# 【★ 只认"技能消耗" ★】文案写的是"自身**技能**成功消费" —— lib/on_consume 里
#   这条派发已经带 `src:"skill"`，装备被动顺手消耗（失血/归息那类）不会误触发。
# 【★ 节流（12 秒）排在给状态之前 ★】先判后记账，别写反。
# ============================================================

# ① 穿着门控（护腿）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["gyre"]}] run return 0

# ② 12 秒节流（zx.gy_cd = 下次可触发刻）
scoreboard players add @s zx.gy_cd 0
execute if score @s zx.gy_cd > #now manacore.meta run return 0

# ③ 「旋步」6 秒（120 刻）
scoreboard players operation @s zx.gy_wd = #now manacore.meta
scoreboard players add @s zx.gy_wd 120

# ④ 节流记账（240 刻）
scoreboard players operation @s zx.gy_cd = #now manacore.meta
scoreboard players add @s zx.gy_cd 240

# ⑤ 表现：脚下一圈青色的水纹（旋步就绪）
execute at @s run particle minecraft:dust{color:[0.25,0.7,0.85],scale:1.4} ~ ~0.15 ~ 0.6 0.05 0.6 0.02 16 normal
execute at @s run particle minecraft:bubble ~ ~0.2 ~ 0.4 0.05 0.4 0.02 8 normal
execute at @s run playsound minecraft:block.bubble_column.upwards_ambient player @a ~ ~ ~ 0.6 1.5
