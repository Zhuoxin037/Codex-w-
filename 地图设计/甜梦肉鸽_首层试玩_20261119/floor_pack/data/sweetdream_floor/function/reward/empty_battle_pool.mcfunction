data remove storage sweetdream_floor:run exact_tier
data remove storage sweetdream_floor:run battle_draw
scoreboard players set #phase sd.floor 1
tellraw @s {"text":"该档没有当前职业可抽取的装备。","color":"gray"}
