execute if score @s zx.j_init matches 1 run return 0
scoreboard players add @s zx.job 0
scoreboard players set @s zx.j_init 1
scoreboard players set @s zx.j_mm 100
execute store result score @s zx.j_at run attribute @s minecraft:attack_damage base get
scoreboard players set @s zx.j_hp 20
scoreboard players set @s zx.j_rg 1000
scoreboard players set @s zx.j_form 0
scoreboard players set @s zx.j_aw 0
scoreboard players set @s zx.j_orb 0
scoreboard players set @s zx.j_prop 0
scoreboard players set @s zx.j_b_sum 0
scoreboard players set @s zx.j_reborn 0

scoreboard players set @s zx.j_pain -1
scoreboard players set @s zx.j_lastdeath 0
scoreboard players add @s zx.j_f_given 0

# A brand-new framework record may have sampled the currently held weapon. Normalize
# only that new record; existing records retain all currently booked gear contributions.
execute if entity @s[tag=zx.j_new_record] run function sweetdream:profession/seed_new
tag @s remove zx.j_new_record
