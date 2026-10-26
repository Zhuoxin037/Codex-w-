$function sweetdream:tag/mark_one {mark:"$(mark)"}
$data modify storage zx:work owned_mark_kind set value {mark:"$(mark)"}
execute unless data storage zx:work owned_mark_kind{mark:"dream"} run return 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run function sweetdream:equipment/armor/late_dusk/gain
