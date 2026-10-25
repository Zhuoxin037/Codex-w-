$execute if entity @e[tag=sd.hk.rig,scores={aj.id=$(id)},distance=0..,limit=1] run return 0
$function sweetdream:boss/husk/bar/remove {id:$(id)}
kill @s
