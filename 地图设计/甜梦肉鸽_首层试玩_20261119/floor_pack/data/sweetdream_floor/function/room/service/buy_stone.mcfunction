$execute unless data storage zx:config oldef."$(id)" run return run tellraw @s {"text":"这件装备没有可用的超限石。","color":"yellow"}
$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{ol:"$(id)"}] run return run tellraw @s {"text":"这件装备已经超限。","color":"yellow"}
execute unless score #lumen sd.floor matches 3.. run return run tellraw @s {"text":"梦屑不足。","color":"yellow"}
scoreboard players remove #lumen sd.floor 3
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
$function sweetdream:overlimit/item/$(id)
tellraw @s {"text":"把原装备移到副手，拿着超限石右键。","color":"light_purple"}
