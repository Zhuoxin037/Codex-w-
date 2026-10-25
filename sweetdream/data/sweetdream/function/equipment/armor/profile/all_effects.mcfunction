$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] at @s run function sweetdream:equipment/armor/profile/set_spend_effect
$function sweetdream:equipment/armor/profile/payout_effects {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
