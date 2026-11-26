$execute if entity @s[tag=zx.status.liuhuo] run function fallendream:equipment/armor/bright_candle/on_hit {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$function fallendream:equipment/armor/borrow_fire/on_hit {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=zx.status.dream] run function fallendream:equipment/armor/late_dusk/hit {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=zx.status.shixin] run function fallendream:equipment/armor/profile/count {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=zx.status.shixin,tag=zx.hv_pump] run function fallendream:equipment/armor/profile/set_bonus {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}

$execute if entity @s[tag=zx.status.shixin] run data modify storage zx:work nsu set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute if entity @s[tag=zx.status.shixin] run function fallendream:equipment/armor/needle_sleep/ol_probe

