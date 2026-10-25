# Read the controller target; does not choose or modify an enemy.
data modify storage sweetdream:aggro out set value {success:false}
execute if entity @s[tag=sd.fb.body] run function sweetdream:boss/fireaxe/target/get
execute if entity @s[tag=sd.kn.body] run function sweetdream:boss/knight/target/get
execute if entity @s[tag=sd.hk.body] run function sweetdream:boss/husk/target/get
