$kill @e[tag=zx.j_twin,distance=0..,nbt={data:{owner:"$(uuid)"}}]
$data modify storage zx:jobs p."$(uuid)".twin.pos set from entity @e[tag=zx.j_host_pick,limit=1] Pos
$data modify storage zx:jobs p."$(uuid)".twin.dim set from entity @s Dimension
data modify storage zx:work jwatch set value {owner:"",u0:0,u1:0,u2:0,u3:0,t0:0,t1:0,t2:0,t3:0}
$data modify storage zx:work jwatch.owner set value "$(uuid)"
$data modify storage zx:work jwatch.u0 set value $(u0)
execute store result storage zx:work jwatch.t0 int 1 run data get entity @e[tag=zx.j_host_pick,limit=1] UUID[0]
$data modify storage zx:work jwatch.u1 set value $(u1)
execute store result storage zx:work jwatch.t1 int 1 run data get entity @e[tag=zx.j_host_pick,limit=1] UUID[1]
$data modify storage zx:work jwatch.u2 set value $(u2)
execute store result storage zx:work jwatch.t2 int 1 run data get entity @e[tag=zx.j_host_pick,limit=1] UUID[2]
$data modify storage zx:work jwatch.u3 set value $(u3)
execute store result storage zx:work jwatch.t3 int 1 run data get entity @e[tag=zx.j_host_pick,limit=1] UUID[3]
execute at @e[tag=zx.j_host_pick,limit=1] run summon minecraft:marker ~ ~ ~ {Tags:["zx.j_host_watch","zx.j_host_watch_new"],data:{}}
data modify entity @e[tag=zx.j_host_watch_new,limit=1] data set from storage zx:work jwatch
tag @e[tag=zx.j_host_watch_new] remove zx.j_host_watch_new
