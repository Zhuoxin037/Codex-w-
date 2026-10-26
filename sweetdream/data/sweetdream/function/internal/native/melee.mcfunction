$scoreboard players set #nh_melee zx.meta $(melee)
$scoreboard players set #nh_charge zx.meta $(charged)
execute unless score #nh_melee zx.meta matches 1 unless score #nh_charge zx.meta matches 1 run return 0
execute unless score #nh_melee zx.meta matches 1 run return 0
execute unless score #nh_charge zx.meta matches 1 run return 0
execute if entity @s[tag=zx.status.liuhuo] run return 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
scoreboard players set #nh_ready zx.meta 0
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["borrow_fire"]}] if score @s zx.bf_rdy matches 1 run scoreboard players set #nh_ready zx.meta 1
execute unless score #nh_ready zx.meta matches 1 run return 0
execute as @a[tag=zx.ub,limit=1] run scoreboard players set @s zx.bf_rdy 0
$data modify storage zx:work bf set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:equipment/armor/borrow_fire/strike with storage zx:work bf

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players set @s zx.bf_rdy 0
