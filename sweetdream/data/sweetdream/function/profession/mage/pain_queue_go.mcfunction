$execute unless data storage zx:jobs p."$(uuid)".pains[0] run scoreboard players set @s zx.j_pain_n 0
$execute unless data storage zx:jobs p."$(uuid)".pains[0] run return 0
$data modify storage zx:work jp_current set from storage zx:jobs p."$(uuid)".pains[0]
execute store result score #jp_due zx.meta run data get storage zx:work jp_current.end
execute if score #jp_due zx.meta > #now manacore.meta run return 0
execute store result score @s zx.j_pain_book run data get storage zx:work jp_current.book
execute store result score @s zx.j_pain_sor run data get storage zx:work jp_current.sor
execute store result score @s zx.j_grace run data get storage zx:work jp_current.no_self
# Pop before dealing damage; death/role-reset callbacks may clear the entire queue.
$data remove storage zx:jobs p."$(uuid)".pains[0]
scoreboard players remove @s zx.j_pain_n 1
scoreboard players operation @s zx.j_pain_gate = #now manacore.meta
scoreboard players add @s zx.j_pain_gate 10
function sweetdream:profession/mage/pain_end
