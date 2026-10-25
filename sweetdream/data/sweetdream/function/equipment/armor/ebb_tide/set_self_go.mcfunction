$execute unless entity @e[tag=zx.et_set,distance=..2.5,nbt={data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}},limit=1] run return 0
# self_step already added the first percent; the set adds one more, then reapplies.
scoreboard players add @s zx.et_s 1
execute if score @s zx.et_s matches 21.. run scoreboard players set @s zx.et_s 20
function sweetdream:equipment/armor/ebb_tide/speed_up
