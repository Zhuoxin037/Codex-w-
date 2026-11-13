# @s=本次准确受害者。实际损失保存在调用栈，不把未受伤玩家当有效命中。
data modify storage zx:work se_hits append value {hp:0,ab:0}
execute store result storage zx:work se_hits[-1].hp int 1 run data get entity @s Health 1000
execute store result storage zx:work se_hits[-1].ab int 1 run data get entity @s AbsorptionAmount 1000
$data modify storage zx:work a set value {target:"@s",type:"sweetdream:true_damage",uncapped:1b,num:$(v),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute if entity @s[type=minecraft:player] run data modify storage zx:work a.type set value "sweetdream:skill"
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
scoreboard players set #se_after zx.meta 0
scoreboard players set #se_ab zx.meta 0
execute store result score #se_after zx.meta run data get entity @s Health 1000
execute store result score #se_ab zx.meta run data get entity @s AbsorptionAmount 1000
scoreboard players operation #se_after zx.meta += #se_ab zx.meta
execute store result score #se_before zx.meta run data get storage zx:work se_hits[-1].hp
execute store result score #se_ab zx.meta run data get storage zx:work se_hits[-1].ab
scoreboard players operation #se_before zx.meta += #se_ab zx.meta
execute if entity @s[type=minecraft:player] if score #se_before zx.meta > #se_after zx.meta run function sweetdream:equipment/staff/surge_ebb/buff
data remove storage zx:work se_hits[-1]
