$data modify storage zx:jobs p."$(uuid)".twin set value {hp:5.0,mana:130.0}
tellraw @s {"text":"同生体已再生。","color":"light_purple"}
