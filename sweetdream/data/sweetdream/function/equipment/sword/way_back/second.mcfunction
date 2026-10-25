function sweetdream:lib/uuid
data modify storage zx:work owner_arg set from storage zx:data self
execute if data storage zx:data self{ok:1b} run function sweetdream:equipment/sword/way_back/second_go with storage zx:work owner_arg
