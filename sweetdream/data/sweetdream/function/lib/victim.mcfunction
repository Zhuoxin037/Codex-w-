# 精确归属，唯一候选才兑现；不猜附近他人的受伤者。已登记尸体以UUID字面量查询。
data remove storage zx:victim context
data remove storage zx:victim candidate
scoreboard players set #vx_count zx.meta 0
tag @a[tag=zx.vx_owner] remove zx.vx_owner
tag @s add zx.vx_owner
data modify storage zx:work v set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work v.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work v.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work v.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work v.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:lib/victim_go with storage zx:work v
tag @s remove zx.vx_owner
execute unless score #vx_count zx.meta matches 1 run return 0
data modify storage zx:victim context set from storage zx:victim candidate
