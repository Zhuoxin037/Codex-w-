execute if score @s sdbf.age matches 10 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/dash_loop/play_exclusive
execute if score @s sdbf.age matches 20 as @e[tag=sd.fb.current_rig,limit=1,distance=0..] run function sweetdream_boss:reconstruction/animations/dash_stop/play_exclusive
function sweetdream:boss/fireaxe/motion/short
execute if score @s sdbf.age matches 33.. run function sweetdream:boss/fireaxe/finish
