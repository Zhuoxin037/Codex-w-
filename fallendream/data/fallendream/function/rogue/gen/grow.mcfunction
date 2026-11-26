data modify storage zx:rogue floor.candidates set value []
execute if data storage zx:rogue floor.cells[{cell:0,present:1b}] unless data storage zx:rogue floor.cells[{cell:1,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:0,dst:1,edge:0}
execute if data storage zx:rogue floor.cells[{cell:1,present:1b}] unless data storage zx:rogue floor.cells[{cell:0,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:1,dst:0,edge:0}
execute if data storage zx:rogue floor.cells[{cell:1,present:1b}] unless data storage zx:rogue floor.cells[{cell:2,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:1,dst:2,edge:1}
execute if data storage zx:rogue floor.cells[{cell:2,present:1b}] unless data storage zx:rogue floor.cells[{cell:1,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:2,dst:1,edge:1}
execute if data storage zx:rogue floor.cells[{cell:2,present:1b}] unless data storage zx:rogue floor.cells[{cell:3,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:2,dst:3,edge:2}
execute if data storage zx:rogue floor.cells[{cell:3,present:1b}] unless data storage zx:rogue floor.cells[{cell:2,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:3,dst:2,edge:2}
execute if data storage zx:rogue floor.cells[{cell:3,present:1b}] unless data storage zx:rogue floor.cells[{cell:4,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:3,dst:4,edge:3}
execute if data storage zx:rogue floor.cells[{cell:4,present:1b}] unless data storage zx:rogue floor.cells[{cell:3,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:4,dst:3,edge:3}
execute if data storage zx:rogue floor.cells[{cell:5,present:1b}] unless data storage zx:rogue floor.cells[{cell:6,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:5,dst:6,edge:4}
execute if data storage zx:rogue floor.cells[{cell:6,present:1b}] unless data storage zx:rogue floor.cells[{cell:5,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:6,dst:5,edge:4}
execute if data storage zx:rogue floor.cells[{cell:6,present:1b}] unless data storage zx:rogue floor.cells[{cell:7,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:6,dst:7,edge:5}
execute if data storage zx:rogue floor.cells[{cell:7,present:1b}] unless data storage zx:rogue floor.cells[{cell:6,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:7,dst:6,edge:5}
execute if data storage zx:rogue floor.cells[{cell:7,present:1b}] unless data storage zx:rogue floor.cells[{cell:8,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:7,dst:8,edge:6}
execute if data storage zx:rogue floor.cells[{cell:8,present:1b}] unless data storage zx:rogue floor.cells[{cell:7,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:8,dst:7,edge:6}
execute if data storage zx:rogue floor.cells[{cell:8,present:1b}] unless data storage zx:rogue floor.cells[{cell:9,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:8,dst:9,edge:7}
execute if data storage zx:rogue floor.cells[{cell:9,present:1b}] unless data storage zx:rogue floor.cells[{cell:8,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:9,dst:8,edge:7}
execute if data storage zx:rogue floor.cells[{cell:10,present:1b}] unless data storage zx:rogue floor.cells[{cell:11,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:10,dst:11,edge:8}
execute if data storage zx:rogue floor.cells[{cell:11,present:1b}] unless data storage zx:rogue floor.cells[{cell:10,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:11,dst:10,edge:8}
execute if data storage zx:rogue floor.cells[{cell:11,present:1b}] unless data storage zx:rogue floor.cells[{cell:12,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:11,dst:12,edge:9}
execute if data storage zx:rogue floor.cells[{cell:12,present:1b}] unless data storage zx:rogue floor.cells[{cell:11,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:12,dst:11,edge:9}
execute if data storage zx:rogue floor.cells[{cell:12,present:1b}] unless data storage zx:rogue floor.cells[{cell:13,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:12,dst:13,edge:10}
execute if data storage zx:rogue floor.cells[{cell:13,present:1b}] unless data storage zx:rogue floor.cells[{cell:12,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:13,dst:12,edge:10}
execute if data storage zx:rogue floor.cells[{cell:13,present:1b}] unless data storage zx:rogue floor.cells[{cell:14,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:13,dst:14,edge:11}
execute if data storage zx:rogue floor.cells[{cell:14,present:1b}] unless data storage zx:rogue floor.cells[{cell:13,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:14,dst:13,edge:11}
execute if data storage zx:rogue floor.cells[{cell:15,present:1b}] unless data storage zx:rogue floor.cells[{cell:16,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:15,dst:16,edge:12}
execute if data storage zx:rogue floor.cells[{cell:16,present:1b}] unless data storage zx:rogue floor.cells[{cell:15,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:16,dst:15,edge:12}
execute if data storage zx:rogue floor.cells[{cell:16,present:1b}] unless data storage zx:rogue floor.cells[{cell:17,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:16,dst:17,edge:13}
execute if data storage zx:rogue floor.cells[{cell:17,present:1b}] unless data storage zx:rogue floor.cells[{cell:16,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:17,dst:16,edge:13}
execute if data storage zx:rogue floor.cells[{cell:17,present:1b}] unless data storage zx:rogue floor.cells[{cell:18,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:17,dst:18,edge:14}
execute if data storage zx:rogue floor.cells[{cell:18,present:1b}] unless data storage zx:rogue floor.cells[{cell:17,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:18,dst:17,edge:14}
execute if data storage zx:rogue floor.cells[{cell:18,present:1b}] unless data storage zx:rogue floor.cells[{cell:19,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:18,dst:19,edge:15}
execute if data storage zx:rogue floor.cells[{cell:19,present:1b}] unless data storage zx:rogue floor.cells[{cell:18,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:19,dst:18,edge:15}
execute if data storage zx:rogue floor.cells[{cell:20,present:1b}] unless data storage zx:rogue floor.cells[{cell:21,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:20,dst:21,edge:16}
execute if data storage zx:rogue floor.cells[{cell:21,present:1b}] unless data storage zx:rogue floor.cells[{cell:20,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:21,dst:20,edge:16}
execute if data storage zx:rogue floor.cells[{cell:21,present:1b}] unless data storage zx:rogue floor.cells[{cell:22,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:21,dst:22,edge:17}
execute if data storage zx:rogue floor.cells[{cell:22,present:1b}] unless data storage zx:rogue floor.cells[{cell:21,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:22,dst:21,edge:17}
execute if data storage zx:rogue floor.cells[{cell:22,present:1b}] unless data storage zx:rogue floor.cells[{cell:23,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:22,dst:23,edge:18}
execute if data storage zx:rogue floor.cells[{cell:23,present:1b}] unless data storage zx:rogue floor.cells[{cell:22,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:23,dst:22,edge:18}
execute if data storage zx:rogue floor.cells[{cell:23,present:1b}] unless data storage zx:rogue floor.cells[{cell:24,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:23,dst:24,edge:19}
execute if data storage zx:rogue floor.cells[{cell:24,present:1b}] unless data storage zx:rogue floor.cells[{cell:23,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:24,dst:23,edge:19}
execute if data storage zx:rogue floor.cells[{cell:0,present:1b}] unless data storage zx:rogue floor.cells[{cell:5,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:0,dst:5,edge:20}
execute if data storage zx:rogue floor.cells[{cell:5,present:1b}] unless data storage zx:rogue floor.cells[{cell:0,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:5,dst:0,edge:20}
execute if data storage zx:rogue floor.cells[{cell:1,present:1b}] unless data storage zx:rogue floor.cells[{cell:6,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:1,dst:6,edge:21}
execute if data storage zx:rogue floor.cells[{cell:6,present:1b}] unless data storage zx:rogue floor.cells[{cell:1,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:6,dst:1,edge:21}
execute if data storage zx:rogue floor.cells[{cell:2,present:1b}] unless data storage zx:rogue floor.cells[{cell:7,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:2,dst:7,edge:22}
execute if data storage zx:rogue floor.cells[{cell:7,present:1b}] unless data storage zx:rogue floor.cells[{cell:2,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:7,dst:2,edge:22}
execute if data storage zx:rogue floor.cells[{cell:3,present:1b}] unless data storage zx:rogue floor.cells[{cell:8,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:3,dst:8,edge:23}
execute if data storage zx:rogue floor.cells[{cell:8,present:1b}] unless data storage zx:rogue floor.cells[{cell:3,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:8,dst:3,edge:23}
execute if data storage zx:rogue floor.cells[{cell:4,present:1b}] unless data storage zx:rogue floor.cells[{cell:9,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:4,dst:9,edge:24}
execute if data storage zx:rogue floor.cells[{cell:9,present:1b}] unless data storage zx:rogue floor.cells[{cell:4,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:9,dst:4,edge:24}
execute if data storage zx:rogue floor.cells[{cell:5,present:1b}] unless data storage zx:rogue floor.cells[{cell:10,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:5,dst:10,edge:25}
execute if data storage zx:rogue floor.cells[{cell:10,present:1b}] unless data storage zx:rogue floor.cells[{cell:5,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:10,dst:5,edge:25}
execute if data storage zx:rogue floor.cells[{cell:6,present:1b}] unless data storage zx:rogue floor.cells[{cell:11,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:6,dst:11,edge:26}
execute if data storage zx:rogue floor.cells[{cell:11,present:1b}] unless data storage zx:rogue floor.cells[{cell:6,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:11,dst:6,edge:26}
execute if data storage zx:rogue floor.cells[{cell:7,present:1b}] unless data storage zx:rogue floor.cells[{cell:12,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:7,dst:12,edge:27}
execute if data storage zx:rogue floor.cells[{cell:12,present:1b}] unless data storage zx:rogue floor.cells[{cell:7,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:12,dst:7,edge:27}
execute if data storage zx:rogue floor.cells[{cell:8,present:1b}] unless data storage zx:rogue floor.cells[{cell:13,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:8,dst:13,edge:28}
execute if data storage zx:rogue floor.cells[{cell:13,present:1b}] unless data storage zx:rogue floor.cells[{cell:8,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:13,dst:8,edge:28}
execute if data storage zx:rogue floor.cells[{cell:9,present:1b}] unless data storage zx:rogue floor.cells[{cell:14,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:9,dst:14,edge:29}
execute if data storage zx:rogue floor.cells[{cell:14,present:1b}] unless data storage zx:rogue floor.cells[{cell:9,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:14,dst:9,edge:29}
execute if data storage zx:rogue floor.cells[{cell:10,present:1b}] unless data storage zx:rogue floor.cells[{cell:15,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:10,dst:15,edge:30}
execute if data storage zx:rogue floor.cells[{cell:15,present:1b}] unless data storage zx:rogue floor.cells[{cell:10,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:15,dst:10,edge:30}
execute if data storage zx:rogue floor.cells[{cell:11,present:1b}] unless data storage zx:rogue floor.cells[{cell:16,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:11,dst:16,edge:31}
execute if data storage zx:rogue floor.cells[{cell:16,present:1b}] unless data storage zx:rogue floor.cells[{cell:11,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:16,dst:11,edge:31}
execute if data storage zx:rogue floor.cells[{cell:12,present:1b}] unless data storage zx:rogue floor.cells[{cell:17,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:12,dst:17,edge:32}
execute if data storage zx:rogue floor.cells[{cell:17,present:1b}] unless data storage zx:rogue floor.cells[{cell:12,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:17,dst:12,edge:32}
execute if data storage zx:rogue floor.cells[{cell:13,present:1b}] unless data storage zx:rogue floor.cells[{cell:18,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:13,dst:18,edge:33}
execute if data storage zx:rogue floor.cells[{cell:18,present:1b}] unless data storage zx:rogue floor.cells[{cell:13,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:18,dst:13,edge:33}
execute if data storage zx:rogue floor.cells[{cell:14,present:1b}] unless data storage zx:rogue floor.cells[{cell:19,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:14,dst:19,edge:34}
execute if data storage zx:rogue floor.cells[{cell:19,present:1b}] unless data storage zx:rogue floor.cells[{cell:14,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:19,dst:14,edge:34}
execute if data storage zx:rogue floor.cells[{cell:15,present:1b}] unless data storage zx:rogue floor.cells[{cell:20,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:15,dst:20,edge:35}
execute if data storage zx:rogue floor.cells[{cell:20,present:1b}] unless data storage zx:rogue floor.cells[{cell:15,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:20,dst:15,edge:35}
execute if data storage zx:rogue floor.cells[{cell:16,present:1b}] unless data storage zx:rogue floor.cells[{cell:21,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:16,dst:21,edge:36}
execute if data storage zx:rogue floor.cells[{cell:21,present:1b}] unless data storage zx:rogue floor.cells[{cell:16,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:21,dst:16,edge:36}
execute if data storage zx:rogue floor.cells[{cell:17,present:1b}] unless data storage zx:rogue floor.cells[{cell:22,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:17,dst:22,edge:37}
execute if data storage zx:rogue floor.cells[{cell:22,present:1b}] unless data storage zx:rogue floor.cells[{cell:17,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:22,dst:17,edge:37}
execute if data storage zx:rogue floor.cells[{cell:18,present:1b}] unless data storage zx:rogue floor.cells[{cell:23,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:18,dst:23,edge:38}
execute if data storage zx:rogue floor.cells[{cell:23,present:1b}] unless data storage zx:rogue floor.cells[{cell:18,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:23,dst:18,edge:38}
execute if data storage zx:rogue floor.cells[{cell:19,present:1b}] unless data storage zx:rogue floor.cells[{cell:24,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:19,dst:24,edge:39}
execute if data storage zx:rogue floor.cells[{cell:24,present:1b}] unless data storage zx:rogue floor.cells[{cell:19,present:1b}] run data modify storage zx:rogue floor.candidates append value {src:24,dst:19,edge:39}
execute store result score #rd_size zx.meta run data get storage zx:rogue floor.candidates
execute if score #rd_size zx.meta matches 0 run return fail
scoreboard players remove #rd_size zx.meta 1
data modify storage zx:work rd_pick set value {}
execute store result storage zx:work rd_pick.max int 1 run scoreboard players get #rd_size zx.meta
function fallendream:rogue/gen/random with storage zx:work rd_pick
function fallendream:rogue/gen/pick with storage zx:work rd_pick
function fallendream:rogue/gen/grow_apply with storage zx:work rd_chosen
scoreboard players add #rd_count zx.meta 1
execute if score #rd_count zx.meta matches ..15 run function fallendream:rogue/gen/grow
