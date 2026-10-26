data modify storage zx:work nh_snapshot set from entity @s
scoreboard players set #nh_hp zx.meta 0
scoreboard players set #nh_ab zx.meta 0
scoreboard players set #nh_stamp zx.meta 0
execute store result score #nh_hp zx.meta run data get storage zx:work nh_snapshot.Health 1000
execute if data storage zx:work nh_snapshot.AbsorptionAmount store result score #nh_ab zx.meta run data get storage zx:work nh_snapshot.AbsorptionAmount 1000
execute if data storage zx:work nh_snapshot.ticks_since_last_hurt_by_mob store result score #nh_stamp zx.meta run data get storage zx:work nh_snapshot.ticks_since_last_hurt_by_mob
execute if score #nh_hp zx.meta >= @s zx.nh_hp if score #nh_ab zx.meta >= @s zx.nh_ab run return run function sweetdream:internal/native/update_seen
# Stamp before any proc damage can recurse through an advancement.
scoreboard players operation @s zx.nh_hp = #nh_hp zx.meta
scoreboard players operation @s zx.nh_ab = #nh_ab zx.meta
scoreboard players operation @s zx.nh_stamp = #nh_stamp zx.meta
execute if entity @s[tag=zx.lr_watch] run data modify storage zx:work lr_snapshot set from storage zx:work nh_snapshot
execute if entity @s[tag=zx.lr_watch] run function sweetdream:equipment/armor/late_dusk/watch_apply
# A previously primed ordinary attack is consumed before this hit primes another one.
$execute if data storage zx:work native_stack[-1].charged run function sweetdream:internal/native/melee {melee:$(melee),charged:$(charged),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
$function sweetdream:internal/native/procs {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
