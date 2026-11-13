# 每个目标单独投递；宏参数在入口冻结，不借用可能被嵌套调用改写的se。
$data modify storage zx:work se_pulse set value {v:$(v),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute as @e[type=!#sweetdream:no_damage,distance=..5] run function sweetdream:equipment/staff/surge_ebb/one with storage zx:work se_pulse
execute as @a[tag=!zx.se_c,distance=..5] run function sweetdream:equipment/staff/surge_ebb/one with storage zx:work se_pulse
summon minecraft:marker ~ ~ ~ {Tags:["zx.se_src"]}
execute as @e[type=!#sweetdream:no_damage,distance=..5] at @s facing entity @e[tag=zx.se_src,distance=..64,limit=1] feet positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~
kill @e[tag=zx.se_src,distance=..64,limit=1]
