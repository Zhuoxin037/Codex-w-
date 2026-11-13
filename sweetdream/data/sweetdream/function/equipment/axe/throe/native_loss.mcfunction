execute if data entity @s {Health:0.0f} run return 0
scoreboard players set #pn_after zx.meta 0
scoreboard players set #pn_ab zx.meta 0
execute store result score #pn_after zx.meta run data get entity @s Health 1000
execute store result score #pn_ab zx.meta run data get entity @s AbsorptionAmount 1000
scoreboard players operation #pn_after zx.meta += #pn_ab zx.meta
execute store result score #pn_loss zx.meta run data get storage zx:work pn_samples[-1].hp
execute store result score #pn_ab zx.meta run data get storage zx:work pn_samples[-1].ab
scoreboard players operation #pn_loss zx.meta += #pn_ab zx.meta
scoreboard players operation #pn_loss zx.meta -= #pn_after zx.meta
execute unless score #pn_loss zx.meta matches 10.. run return 0
scoreboard players operation #pn_loss zx.meta /= #10 zx.meta
data modify storage zx:work a set value {target:"@s",num:0.0,type:"sweetdream:true_damage",uncapped:1b,fixed:1b,pn_extra:1b,src:"enemy",u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work a.num double 0.001 run scoreboard players get #pn_loss zx.meta
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
