# A real origin relation, not a nearest-arrow or nearest-player guess.
scoreboard players set #shot_owner zx.meta 0
execute on origin if entity @s[type=player,tag=zx.shot_owner] run scoreboard players set #shot_owner zx.meta 1
execute unless score #shot_owner zx.meta matches 1 run return 0
function sweetdream:internal/bow/bind_go with storage zx:work shot
