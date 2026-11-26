# Public interface: execute as the custom boss carrier at its position.
# Input: target UUID integers u0..u3. Output: fallendream:aggro out.success.
data modify storage fallendream:aggro out set value {success:false}
$execute if entity @s[tag=sd.fb.body] run function fallendream:boss/fireaxe/target/redirect {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=sd.kn.body] run function fallendream:boss/knight/target/redirect {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=sd.hk.body] run function fallendream:boss/husk/target/redirect {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$execute if entity @s[tag=sd.bs.body] run function fallendream:boss/b_staff/target/redirect {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
