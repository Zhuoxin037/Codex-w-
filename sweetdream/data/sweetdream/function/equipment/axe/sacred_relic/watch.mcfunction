# 装备回调维护。原版 post_attack 读取攻击者的主手物品。
# 副手圣骸时给当前主手临时挂同一监听, 保留其其他附魔; 离手后移除此监听。
# 新旧圣骸都能用, 不依赖重新 /give。没有伤害或冷却加成。
function sweetdream:equipment/axe/sacred_relic/held
execute if score #sr_held zx.meta matches 1 run scoreboard players set @s zx.sr_lt 1
execute if score #sr_held zx.meta matches 1 if items entity @s weapon.mainhand * unless items entity @s weapon.mainhand *[enchantments~[{enchantments:"sweetdream:sacred_relic"}]] run item modify entity @s weapon.mainhand sweetdream:sacred_relic/listen
execute if score #sr_held zx.meta matches 0 if items entity @s weapon.mainhand *[enchantments~[{enchantments:"sweetdream:sacred_relic"}]] run item modify entity @s weapon.mainhand sweetdream:sacred_relic/unlisten
execute if score #sr_held zx.meta matches 0 if score @s zx.sr_lt matches 1.. run function sweetdream:equipment/axe/sacred_relic/unlisten_inventory
execute if score #sr_held zx.meta matches 0 run scoreboard players set @s zx.sr_lt 0
