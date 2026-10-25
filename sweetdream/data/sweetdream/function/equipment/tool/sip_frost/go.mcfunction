# ============================================================
# sweetdream:equipment/tool/sip_frost/go —— 饮霜触发：5 格内最近 2 个生物缓慢Ⅱ 3 秒
# ------------------------------------------------------------
# 【触发点】watch.mcfunction（治疗量累计满 10 且 4 秒限频已过）
# 【为什么给 3 秒而效果是"触发一次"】设计原文就是"3 秒缓慢Ⅱ"，不是"离开就消失"，
#   所以这里正常给时长，不做每秒刷新。
# ============================================================
execute at @s run effect give @e[type=!#sweetdream:no_damage,distance=..5,sort=nearest,limit=2] minecraft:slowness 3 1 true
execute at @s run particle minecraft:dust{color:[0.62,0.85,0.95],scale:1.2} ~ ~0.6 ~ 3.0 0.6 3.0 0.02 24 normal
execute at @s run particle minecraft:snowflake ~ ~0.8 ~ 2.4 0.4 2.4 0.02 16 normal
execute at @s run playsound minecraft:block.powder_snow.break player @a ~ ~ ~ 0.7 1.2
