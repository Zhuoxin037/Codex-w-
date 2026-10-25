# Called once by the common event. Statistic delta survives healing between hits.
# Without interleaved healing, use the exact health difference (millihitpoints).
# With healing, vanilla damage_taken resolves the event to 0.1 HP (±0.05 rounding).
scoreboard players set #hurt_cur zx.meta 0
execute store result score #hurt_cur zx.meta run data get entity @s Health 1000
scoreboard players operation #hurt_delta zx.meta = @s zx.hurt_evt
execute if score @s zx.hp_snap matches 1.. run scoreboard players operation #hurt_delta zx.meta = @s zx.hp_snap
execute if score @s zx.hp_snap matches 1.. run scoreboard players operation #hurt_delta zx.meta -= #hurt_cur zx.meta
scoreboard players operation #hurt_error zx.meta = #hurt_delta zx.meta
scoreboard players operation #hurt_error zx.meta -= @s zx.hurt_evt
execute if score #hurt_error zx.meta matches -50..50 if score #hurt_delta zx.meta matches 0.. run scoreboard players operation @s zx.hurt_evt = #hurt_delta zx.meta
# Lethal overkill is not healing; count at most the previously observed living HP.
execute if score #hurt_cur zx.meta matches ..0 if score @s zx.hp_snap matches 1.. if score @s zx.hurt_evt > @s zx.hp_snap run scoreboard players operation @s zx.hurt_evt = @s zx.hp_snap
# Credit actual interleaved healing to sip_frost before advancing the baseline.
scoreboard players set #sf_gain zx.meta 0
execute if score @s zx.sf_hp matches 1.. run scoreboard players operation #sf_gain zx.meta = #hurt_cur zx.meta
execute if score @s zx.sf_hp matches 1.. run scoreboard players operation #sf_gain zx.meta += @s zx.hurt_evt
execute if score @s zx.sf_hp matches 1.. run scoreboard players operation #sf_gain zx.meta -= @s zx.sf_hp
execute if score #hurt_cur zx.meta matches ..0 run scoreboard players set #sf_gain zx.meta 0
execute if score #sf_gain zx.meta matches 1.. if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sip_frost"]}] run function sweetdream:equipment/tool/sip_frost/gain
scoreboard players operation @s zx.hp_snap = #hurt_cur zx.meta
scoreboard players operation @s zx.hl_hp = #hurt_cur zx.meta
scoreboard players operation @s zx.sf_hp = #hurt_cur zx.meta
scoreboard players operation @s zx.hurt_at = #now manacore.meta
