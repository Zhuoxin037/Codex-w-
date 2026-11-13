$execute as @e[type=!#sweetdream:no_damage,distance=..16,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]}] run function sweetdream:lib/victim/candidate
data modify storage zx:work vx_queue set from storage zx:native registry
execute if data storage zx:work vx_queue[0] run function sweetdream:lib/victim/dead_loop
