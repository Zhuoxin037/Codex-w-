$scoreboard players set #lr_src zx.meta $(amount)
$scoreboard players set #lr_pct zx.meta $(pct)
function manacore:internal/damage/mul_pct {src:"#lr_src",mul:"#lr_pct",obj:"zx.meta"}
execute unless score #mul_out zx.meta matches 1.. run return 0
$data modify storage zx:work a set value {target:"@s",damage:0.0,type:"sweetdream:skill",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute store result storage zx:work a.num double 0.001 run scoreboard players get #mul_out zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
particle minecraft:dust{color:[0.4,0.3,0.55],scale:2.2} ~ ~1 ~ 0.6 0.8 0.6 0.04 30
