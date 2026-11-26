scoreboard players set @s zx.s2_veil_rec 0
# 【超限·复纱】记下死亡当刻, 供"12 秒内重新召唤"判定
scoreboard players operation @s zx.rbv_die = #now manacore.meta
scoreboard players set @s zx.j_reborn 600
execute if score @s zx.j_aw matches 1 run scoreboard players set @s zx.j_reborn 300
execute if score @s zx.j_form matches 1 run function fallendream:profession/twin/return
tellraw @s {"text":"同生体已死亡，正在再生；期间本我者不能自动恢复魔力。","color":"red"}

scoreboard players operation @s zx.j_rb_end = #now manacore.meta
scoreboard players operation @s zx.j_rb_end += @s zx.j_reborn
