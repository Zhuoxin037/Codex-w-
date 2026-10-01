function sweetdream:equipment/sword/sickle_dreams/sweep/target_one with storage zx:sweep queue[0]
data remove storage zx:sweep queue[0]
execute if data storage zx:sweep queue[0] run function sweetdream:equipment/sword/sickle_dreams/sweep/target_loop
