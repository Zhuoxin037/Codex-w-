$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] at @s run function fallendream:equipment/armor/profile/set_spend_effect
$function fallendream:equipment/armor/profile/payout_effects {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
