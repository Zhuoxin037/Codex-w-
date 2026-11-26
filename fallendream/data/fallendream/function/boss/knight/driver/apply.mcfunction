# Macro arguments are bound before the native UUID cache is refreshed.
execute if entity @s[tag=fallendream_boss.dream_knight.animation.wave_slash.playing] run function fallendream_boss:dream_knight/animations/pause_all
execute if entity @s[tag=fallendream_boss.dream_knight.animation.approach_thrust.playing] run function fallendream_boss:dream_knight/animations/pause_all
execute store result storage animated_java:temp args.id int 1 run scoreboard players get @s aj.id
function animated_java:global/data_manager/read with storage animated_java:temp args
$function fallendream_boss:dream_knight/animations/$(clip)/zzz/apply_frame {frame:$(frame)}
