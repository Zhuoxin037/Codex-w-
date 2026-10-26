# Removing the boots clears their dynamic modifier as well as their base modifier.
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["ebb_tide"]}] run scoreboard players set @s zx.et_s 0
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["ebb_tide"]}] run return run function sweetdream:equipment/armor/ebb_tide/speed_up
# ============================================================
# sweetdream:equipment/armor/ebb_tide/self_step —— 玩家这一秒的档位(在浪上 +1 / 离开 -10)
# ------------------------------------------------------------
# 【执行者】玩家(@s)（已确认穿着返汐靴子）  【位置】at @s
# 【★ 文案(逐字)】"自身在海浪上移速将每秒增加 1%，最多增加 20%"。
# ============================================================

# ① 这一秒在不在浪上(任意一片都算 —— 海浪没有归属, 见 wave_new)
execute at @s if entity @e[tag=zx.et_wave,distance=..1,limit=1] run scoreboard players add @s zx.et_s 1
execute at @s unless entity @e[tag=zx.et_wave,distance=..1,limit=1] run scoreboard players remove @s zx.et_s 10

# ② 夹到 0..20
execute if score @s zx.et_s matches 21.. run scoreboard players set @s zx.et_s 20
execute if score @s zx.et_s matches ..0 run scoreboard players set @s zx.et_s 0

# ③ 应用
function sweetdream:equipment/armor/ebb_tide/speed_up

execute if items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] run function sweetdream:equipment/armor/ebb_tide/set_self
