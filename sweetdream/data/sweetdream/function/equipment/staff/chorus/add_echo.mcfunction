$scoreboard players add @e[tag=zx.cs_voice,tag=!zx.cs_support,distance=0..,sort=nearest,limit=1,nbt={data:{owner:"$(uuid)"}}] zx.cs_echo 1
$execute as @e[tag=zx.cs_voice,tag=!zx.cs_support,distance=0..,sort=nearest,limit=1,nbt={data:{owner:"$(uuid)"}}] if score @s zx.cs_echo matches 3.. run scoreboard players set @s zx.cs_echo 2
