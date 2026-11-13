$kill @e[type=minecraft:marker,tag=zx.pn_watch,distance=0..,nbt={data:{sid:$(sid)}}]
$summon minecraft:marker ~ ~ ~ {Tags:["zx.pn_watch"],data:{uuid:"$(uuid)",sid:$(sid),hp:$(hp),ab:$(ab)}}
$scoreboard players set @e[type=minecraft:marker,tag=zx.pn_watch,distance=0..,nbt={data:{uuid:"$(uuid)"}},limit=1] zx.sid $(sid)
