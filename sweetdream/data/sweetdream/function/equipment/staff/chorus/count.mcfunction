scoreboard players set #chorus_n zx.meta 0
$execute store result score #chorus_n zx.meta if entity @e[tag=zx.j_follower,tag=!zx.j_return,tag=!zx.cs_voice,distance=..12,sort=nearest,limit=3,nbt={data:{owner:"$(uuid)"}}]
