function sweetdream:equipment/sword/flame_brokenbody/combat/target_one with storage zx:fbcombat queue[0]
data remove storage zx:fbcombat queue[0]
execute if data storage zx:fbcombat queue[0] run function sweetdream:equipment/sword/flame_brokenbody/combat/target_loop
