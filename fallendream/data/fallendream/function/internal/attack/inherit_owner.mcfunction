scoreboard players set #ac_u zx.meta 0
execute store result score #ac_u zx.meta run data get storage zx:work a.u0
$execute unless score #ac_u zx.meta matches $(u0) run return 0
execute store result score #ac_u zx.meta run data get storage zx:work a.u1
$execute unless score #ac_u zx.meta matches $(u1) run return 0
execute store result score #ac_u zx.meta run data get storage zx:work a.u2
$execute unless score #ac_u zx.meta matches $(u2) run return 0
execute store result score #ac_u zx.meta run data get storage zx:work a.u3
$execute unless score #ac_u zx.meta matches $(u3) run return 0
$data modify storage zx:work a.chain set value $(chain)
