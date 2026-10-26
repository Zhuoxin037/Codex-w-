$execute if entity @s[tag=zx.status.liuhuo] run function sweetdream:equipment/armor/bright_candle/on_hit {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$function sweetdream:equipment/armor/borrow_fire/on_hit {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=zx.status.dream] run function sweetdream:equipment/armor/late_dusk/hit {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=zx.status.shixin] run function sweetdream:equipment/armor/profile/count {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=zx.status.shixin,tag=zx.hv_pump] run function sweetdream:equipment/armor/profile/set_bonus {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
