$execute unless data storage zx:combat ranged_search as @e[type=!#fallendream:no_damage,distance=..16,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]}] run function fallendream:lib/victim/candidate
$execute if data storage zx:combat ranged_search as @e[type=!#fallendream:no_damage,distance=0..,nbt={HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]}] run function fallendream:lib/victim/candidate
data modify storage zx:work vx_queue set from storage zx:native registry
execute if data storage zx:work vx_queue[0] run function fallendream:lib/victim/dead_loop
