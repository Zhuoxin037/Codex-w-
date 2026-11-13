advancement revoke @s only sweetdream:internal/hurt
scoreboard players add @s zx.hurt_total 0
scoreboard players add @s zx.hurt_seen 0
scoreboard players operation @s zx.hurt_evt = @s zx.hurt_total
scoreboard players operation @s zx.hurt_evt -= @s zx.hurt_seen
scoreboard players operation @s zx.hurt_seen = @s zx.hurt_total
execute if score @s zx.hurt_evt matches ..0 run scoreboard players set @s zx.hurt_evt 0
execute if score @s zx.hurt_evt matches 21474837.. run scoreboard players set @s zx.hurt_evt 21474836
scoreboard players operation @s zx.hurt_evt *= #100 zx.meta
execute if entity @s[tag=zx.nr_active] run function sweetdream:equipment/axe/no_return/on_hurt

execute if score @s zx.hurt_evt matches 1.. if items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] at @s run function sweetdream:equipment/armor/glimmer/clear
execute if score @s zx.hurt_evt matches 1.. if score @s zx.ld_r5 matches 1.. run effect clear @s minecraft:resistance
execute if score @s zx.hurt_evt matches 1.. if score @s zx.ld_r5 matches 1.. run scoreboard players set @s zx.ld_r5 0

# [batch22] ---- 2026-11-07 批 22：架势记录伤害 / 涤火受击 ----
#   ★ 必须排在第 15 行那条总门控的 return 0 **之前**：只穿架势或只穿涤火的
#     玩家会在那里提前收工，放在下面这两件会静默永不触发。
execute if score @s zx.hurt_evt matches 1.. run function sweetdream:equipment/sword/stance/record
execute if score @s zx.hurt_evt matches 1.. if items entity @s armor.chest *[minecraft:custom_data~{zx:["purge_fire"]}] at @s run function sweetdream:equipment/armor/purge_fire/hurt
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["huilan"]}] unless items entity @s armor.chest *[minecraft:custom_data~{zx:["bulwark"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["retro_shine"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sip_frost"]}] unless score @s zx.wb_on matches 1 run return 0
function sweetdream:lib/hurt_gain
execute if score @s zx.hurt_evt matches 1.. run function sweetdream:equipment/armor/bulwark/event
execute if score @s zx.hurt_evt matches 1.. run function sweetdream:equipment/armor/huilan/on_hurt
execute if score @s zx.hurt_evt matches 1.. run function sweetdream:equipment/sword/way_back/on_hurt
