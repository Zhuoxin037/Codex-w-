# Reveal this room and its directly connected neighbors, with no second-hop recursion.
data modify storage zx:work rv_current set value {}
execute store result storage zx:work rv_current.cell int 1 run scoreboard players get @s zx.rg_room
function fallendream:rogue/map/reveal_cell with storage zx:work rv_current
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[0]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 0 run function fallendream:rogue/map/reveal_cell {cell:1}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 1 run function fallendream:rogue/map/reveal_cell {cell:0}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[1]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 1 run function fallendream:rogue/map/reveal_cell {cell:2}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 2 run function fallendream:rogue/map/reveal_cell {cell:1}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[2]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 2 run function fallendream:rogue/map/reveal_cell {cell:3}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 3 run function fallendream:rogue/map/reveal_cell {cell:2}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[3]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 3 run function fallendream:rogue/map/reveal_cell {cell:4}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 4 run function fallendream:rogue/map/reveal_cell {cell:3}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[4]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 5 run function fallendream:rogue/map/reveal_cell {cell:6}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 6 run function fallendream:rogue/map/reveal_cell {cell:5}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[5]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 6 run function fallendream:rogue/map/reveal_cell {cell:7}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 7 run function fallendream:rogue/map/reveal_cell {cell:6}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[6]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 7 run function fallendream:rogue/map/reveal_cell {cell:8}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 8 run function fallendream:rogue/map/reveal_cell {cell:7}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[7]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 8 run function fallendream:rogue/map/reveal_cell {cell:9}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 9 run function fallendream:rogue/map/reveal_cell {cell:8}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[8]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 10 run function fallendream:rogue/map/reveal_cell {cell:11}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 11 run function fallendream:rogue/map/reveal_cell {cell:10}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[9]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 11 run function fallendream:rogue/map/reveal_cell {cell:12}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 12 run function fallendream:rogue/map/reveal_cell {cell:11}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[10]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 12 run function fallendream:rogue/map/reveal_cell {cell:13}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 13 run function fallendream:rogue/map/reveal_cell {cell:12}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[11]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 13 run function fallendream:rogue/map/reveal_cell {cell:14}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 14 run function fallendream:rogue/map/reveal_cell {cell:13}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[12]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 15 run function fallendream:rogue/map/reveal_cell {cell:16}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 16 run function fallendream:rogue/map/reveal_cell {cell:15}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[13]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 16 run function fallendream:rogue/map/reveal_cell {cell:17}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 17 run function fallendream:rogue/map/reveal_cell {cell:16}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[14]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 17 run function fallendream:rogue/map/reveal_cell {cell:18}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 18 run function fallendream:rogue/map/reveal_cell {cell:17}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[15]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 18 run function fallendream:rogue/map/reveal_cell {cell:19}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 19 run function fallendream:rogue/map/reveal_cell {cell:18}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[16]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 20 run function fallendream:rogue/map/reveal_cell {cell:21}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 21 run function fallendream:rogue/map/reveal_cell {cell:20}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[17]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 21 run function fallendream:rogue/map/reveal_cell {cell:22}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 22 run function fallendream:rogue/map/reveal_cell {cell:21}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[18]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 22 run function fallendream:rogue/map/reveal_cell {cell:23}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 23 run function fallendream:rogue/map/reveal_cell {cell:22}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[19]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 23 run function fallendream:rogue/map/reveal_cell {cell:24}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 24 run function fallendream:rogue/map/reveal_cell {cell:23}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[20]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 0 run function fallendream:rogue/map/reveal_cell {cell:5}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 5 run function fallendream:rogue/map/reveal_cell {cell:0}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[21]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 1 run function fallendream:rogue/map/reveal_cell {cell:6}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 6 run function fallendream:rogue/map/reveal_cell {cell:1}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[22]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 2 run function fallendream:rogue/map/reveal_cell {cell:7}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 7 run function fallendream:rogue/map/reveal_cell {cell:2}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[23]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 3 run function fallendream:rogue/map/reveal_cell {cell:8}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 8 run function fallendream:rogue/map/reveal_cell {cell:3}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[24]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 4 run function fallendream:rogue/map/reveal_cell {cell:9}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 9 run function fallendream:rogue/map/reveal_cell {cell:4}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[25]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 5 run function fallendream:rogue/map/reveal_cell {cell:10}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 10 run function fallendream:rogue/map/reveal_cell {cell:5}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[26]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 6 run function fallendream:rogue/map/reveal_cell {cell:11}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 11 run function fallendream:rogue/map/reveal_cell {cell:6}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[27]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 7 run function fallendream:rogue/map/reveal_cell {cell:12}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 12 run function fallendream:rogue/map/reveal_cell {cell:7}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[28]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 8 run function fallendream:rogue/map/reveal_cell {cell:13}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 13 run function fallendream:rogue/map/reveal_cell {cell:8}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[29]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 9 run function fallendream:rogue/map/reveal_cell {cell:14}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 14 run function fallendream:rogue/map/reveal_cell {cell:9}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[30]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 10 run function fallendream:rogue/map/reveal_cell {cell:15}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 15 run function fallendream:rogue/map/reveal_cell {cell:10}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[31]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 11 run function fallendream:rogue/map/reveal_cell {cell:16}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 16 run function fallendream:rogue/map/reveal_cell {cell:11}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[32]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 12 run function fallendream:rogue/map/reveal_cell {cell:17}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 17 run function fallendream:rogue/map/reveal_cell {cell:12}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[33]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 13 run function fallendream:rogue/map/reveal_cell {cell:18}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 18 run function fallendream:rogue/map/reveal_cell {cell:13}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[34]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 14 run function fallendream:rogue/map/reveal_cell {cell:19}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 19 run function fallendream:rogue/map/reveal_cell {cell:14}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[35]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 15 run function fallendream:rogue/map/reveal_cell {cell:20}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 20 run function fallendream:rogue/map/reveal_cell {cell:15}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[36]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 16 run function fallendream:rogue/map/reveal_cell {cell:21}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 21 run function fallendream:rogue/map/reveal_cell {cell:16}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[37]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 17 run function fallendream:rogue/map/reveal_cell {cell:22}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 22 run function fallendream:rogue/map/reveal_cell {cell:17}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[38]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 18 run function fallendream:rogue/map/reveal_cell {cell:23}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 23 run function fallendream:rogue/map/reveal_cell {cell:18}
execute store result score #rv_edge zx.meta run data get storage zx:rogue floor.edges[39]
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 19 run function fallendream:rogue/map/reveal_cell {cell:24}
execute if score #rv_edge zx.meta matches 1 if score @s zx.rg_room matches 24 run function fallendream:rogue/map/reveal_cell {cell:19}
