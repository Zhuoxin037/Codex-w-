# 原版附魔 post_attack -> affected:victim。@s 是准确受害者, 即使已死也不重新用 @e 找。
# requirements 已限制玩家伤害; 再确认攻击者当前主/副手持有圣骸。
execute if entity @s[type=#sweetdream:no_damage] run return 0
scoreboard players add #sr_hook zx.meta 1
scoreboard players set #sr_held zx.meta 0
execute on attacker if entity @s[type=minecraft:player] run function sweetdream:equipment/axe/sacred_relic/held
execute unless score #sr_held zx.meta matches 1 run return 0
execute if data entity @s {Health:0.0f} at @s run return run function sweetdream:equipment/axe/sacred_relic/relic_spawn
# 非致死: 保存准确 UUID, 供之后 player_killed_entity 处理烧死等延迟击杀。
execute at @s run function sweetdream:equipment/axe/sacred_relic/observe
