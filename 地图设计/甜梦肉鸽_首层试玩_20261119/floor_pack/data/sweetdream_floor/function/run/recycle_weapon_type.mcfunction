$clear @s *[minecraft:custom_data~{zx:["$(kind)"]}]
$execute if items entity @s enderchest.* *[minecraft:custom_data~{zx:["$(kind)"]}] run function sweetdream_floor:run/recycle_weapon_stash {kind:"$(kind)"}
$data modify storage sweetdream_floor:cleanup weapon.kind set value "$(kind)"
execute if data storage sweetdream_floor:cleanup weapon.uuid run function sweetdream_floor:run/recycle_weapon_queue with storage sweetdream_floor:cleanup weapon
