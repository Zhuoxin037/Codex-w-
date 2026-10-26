$function sweetdream:boss/husk/move {step:$(step)}
$execute if score @s sdh.moved matches 0 at @s rotated ~30 0 run function sweetdream:boss/husk/move {step:$(detour)}
$execute if score @s sdh.moved matches 0 at @s rotated ~-30 0 run function sweetdream:boss/husk/move {step:$(detour)}
$execute if score @s sdh.moved matches 0 at @s positioned ~ ~1 ~ run function sweetdream:boss/husk/move {step:$(detour)}
$execute if score @s sdh.state matches 2 if score @s sdh.moved matches 1 run scoreboard players add @s sdh.walktempo $(bonus)
execute if score @s sdh.walktempo matches 10.. run scoreboard players add @e[tag=sd.hk.current_rig,distance=0..,limit=1] sweetdream_boss.husk.walk.frame 1
execute if score @s sdh.walktempo matches 10.. run scoreboard players remove @s sdh.walktempo 10
