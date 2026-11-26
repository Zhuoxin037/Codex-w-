# Read the controller target; does not choose or modify an enemy.
data modify storage fallendream:aggro out set value {success:false}
execute if entity @s[tag=sd.fb.body] run function fallendream:boss/fireaxe/target/get
execute if entity @s[tag=sd.kn.body] run function fallendream:boss/knight/target/get
execute if entity @s[tag=sd.hk.body] run function fallendream:boss/husk/target/get
execute if entity @s[tag=sd.bs.body] run function fallendream:boss/b_staff/target/get
