$execute as @e[tag=zx.ff_idle,distance=0..,nbt={data:{owner:"$(uuid)"}},sort=nearest,limit=5] run data modify entity @s data.target set value "$(target)"
