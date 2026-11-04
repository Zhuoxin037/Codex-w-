scoreboard players add @s zx.j_ess 0
scoreboard players operation @s zx.j_ess += #cr_restore zx.meta
execute if score @s zx.j_ess > #cr_cap zx.meta run scoreboard players operation @s zx.j_ess = #cr_cap zx.meta
