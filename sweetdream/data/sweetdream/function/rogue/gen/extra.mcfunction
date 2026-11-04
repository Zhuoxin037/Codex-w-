data modify storage zx:rogue floor.candidates set value []
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[0]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:0,present:1b}] if data storage zx:rogue floor.cells[{cell:1,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:0}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[1]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:1,present:1b}] if data storage zx:rogue floor.cells[{cell:2,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:1}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[2]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:2,present:1b}] if data storage zx:rogue floor.cells[{cell:3,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:2}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[3]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:3,present:1b}] if data storage zx:rogue floor.cells[{cell:4,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:3}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[4]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:5,present:1b}] if data storage zx:rogue floor.cells[{cell:6,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:4}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[5]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:6,present:1b}] if data storage zx:rogue floor.cells[{cell:7,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:5}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[6]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:7,present:1b}] if data storage zx:rogue floor.cells[{cell:8,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:6}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[7]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:8,present:1b}] if data storage zx:rogue floor.cells[{cell:9,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:7}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[8]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:10,present:1b}] if data storage zx:rogue floor.cells[{cell:11,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:8}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[9]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:11,present:1b}] if data storage zx:rogue floor.cells[{cell:12,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:9}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[10]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:12,present:1b}] if data storage zx:rogue floor.cells[{cell:13,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:10}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[11]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:13,present:1b}] if data storage zx:rogue floor.cells[{cell:14,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:11}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[12]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:15,present:1b}] if data storage zx:rogue floor.cells[{cell:16,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:12}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[13]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:16,present:1b}] if data storage zx:rogue floor.cells[{cell:17,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:13}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[14]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:17,present:1b}] if data storage zx:rogue floor.cells[{cell:18,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:14}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[15]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:18,present:1b}] if data storage zx:rogue floor.cells[{cell:19,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:15}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[16]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:20,present:1b}] if data storage zx:rogue floor.cells[{cell:21,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:16}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[17]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:21,present:1b}] if data storage zx:rogue floor.cells[{cell:22,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:17}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[18]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:22,present:1b}] if data storage zx:rogue floor.cells[{cell:23,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:18}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[19]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:23,present:1b}] if data storage zx:rogue floor.cells[{cell:24,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:19}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[20]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:0,present:1b}] if data storage zx:rogue floor.cells[{cell:5,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:20}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[21]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:1,present:1b}] if data storage zx:rogue floor.cells[{cell:6,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:21}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[22]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:2,present:1b}] if data storage zx:rogue floor.cells[{cell:7,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:22}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[23]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:3,present:1b}] if data storage zx:rogue floor.cells[{cell:8,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:23}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[24]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:4,present:1b}] if data storage zx:rogue floor.cells[{cell:9,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:24}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[25]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:5,present:1b}] if data storage zx:rogue floor.cells[{cell:10,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:25}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[26]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:6,present:1b}] if data storage zx:rogue floor.cells[{cell:11,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:26}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[27]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:7,present:1b}] if data storage zx:rogue floor.cells[{cell:12,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:27}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[28]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:8,present:1b}] if data storage zx:rogue floor.cells[{cell:13,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:28}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[29]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:9,present:1b}] if data storage zx:rogue floor.cells[{cell:14,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:29}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[30]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:10,present:1b}] if data storage zx:rogue floor.cells[{cell:15,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:30}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[31]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:11,present:1b}] if data storage zx:rogue floor.cells[{cell:16,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:31}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[32]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:12,present:1b}] if data storage zx:rogue floor.cells[{cell:17,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:32}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[33]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:13,present:1b}] if data storage zx:rogue floor.cells[{cell:18,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:33}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[34]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:14,present:1b}] if data storage zx:rogue floor.cells[{cell:19,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:34}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[35]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:15,present:1b}] if data storage zx:rogue floor.cells[{cell:20,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:35}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[36]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:16,present:1b}] if data storage zx:rogue floor.cells[{cell:21,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:36}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[37]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:17,present:1b}] if data storage zx:rogue floor.cells[{cell:22,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:37}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[38]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:18,present:1b}] if data storage zx:rogue floor.cells[{cell:23,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:38}
execute store result score #rd_link zx.meta run data get storage zx:rogue floor.edges[39]
execute if score #rd_link zx.meta matches 0 if data storage zx:rogue floor.cells[{cell:19,present:1b}] if data storage zx:rogue floor.cells[{cell:24,present:1b}] run data modify storage zx:rogue floor.candidates append value {edge:39}
execute store result score #rd_size zx.meta run data get storage zx:rogue floor.candidates
execute if score #rd_size zx.meta matches 0 run return 0
scoreboard players remove #rd_size zx.meta 1
data modify storage zx:work rd_pick set value {}
execute store result storage zx:work rd_pick.max int 1 run scoreboard players get #rd_size zx.meta
function sweetdream:rogue/gen/random with storage zx:work rd_pick
function sweetdream:rogue/gen/pick with storage zx:work rd_pick
function sweetdream:rogue/gen/link_apply with storage zx:work rd_chosen
scoreboard players remove #rd_extra zx.meta 1
execute if score #rd_extra zx.meta matches 1.. run function sweetdream:rogue/gen/extra
