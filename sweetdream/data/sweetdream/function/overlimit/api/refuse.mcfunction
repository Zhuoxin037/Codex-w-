# ============================================================
# sweetdream:overlimit/api/refuse —— 超限敲失败了, 说明原因
# ------------------------------------------------------------
# 【入参】zx:out r.reason = wrong_weapon|already|no_def
# 【为什么不写"装不上"】玩家得知道是"副手不是这把武器"还是"已经超限过了"。
# ============================================================

execute if data storage zx:out r{reason:"wrong_weapon"} run tellraw @s [{"text":"✘ 副手不是这把武器（超限石只对对应的武器生效）","color":"red"}]
execute if data storage zx:out r{reason:"already"} run tellraw @s [{"text":"✘ 这把武器已经超限过了","color":"red"}]
execute if data storage zx:out r{reason:"no_def"} run tellraw @s [{"text":"✘ 这把武器没有超限定义（定义表缺条目）","color":"red"}]
playsound minecraft:entity.villager.no player @s ~ ~ ~ 0.7 1.0
