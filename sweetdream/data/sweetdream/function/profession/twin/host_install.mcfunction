$tag @e[tag=zx.j_host,distance=0..,nbt={data:{jhost:{owner:"$(uuid)"}}}] remove zx.j_host
data modify entity @e[tag=zx.j_host_pick,limit=1] data.jhost set value {owner:"",u0:0,u1:0,u2:0,u3:0}
$data modify entity @e[tag=zx.j_host_pick,limit=1] data.jhost set value {owner:"$(uuid)",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute store result score @s zx.j_host_n run scoreboard players get @e[tag=zx.j_host_pick,limit=1] zx.j_ess
scoreboard players operation @s zx.j_host_t = @s zx.j_host_n
scoreboard players set #j160 zx.meta 160
scoreboard players operation @s zx.j_host_t *= #j160 zx.meta
scoreboard players set @e[tag=zx.j_host_pick,limit=1] zx.j_ess 0
tag @e[tag=zx.j_host_pick,limit=1] add zx.j_host

function sweetdream:profession/twin/host_watch_new with storage zx:work jt
