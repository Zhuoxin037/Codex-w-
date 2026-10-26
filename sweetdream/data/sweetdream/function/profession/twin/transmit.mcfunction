function sweetdream:profession/twin/locate
scoreboard players operation #jem_got zx.meta /= #j2 zx.meta
execute store result storage zx:work jem.amount double .001 run scoreboard players get #jem_got zx.meta
execute as @e[tag=zx.j_anchor,limit=1] run function sweetdream:profession/berserker/self_damage with storage zx:work jem
