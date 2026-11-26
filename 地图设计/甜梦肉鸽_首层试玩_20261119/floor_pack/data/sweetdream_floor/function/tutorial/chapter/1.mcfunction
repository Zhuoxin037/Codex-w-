data merge block -100 90 46 {Page:0,Book:{id:"minecraft:written_book",count:1,components:{"minecraft:written_book_content":{title:"1. 施法，魔力和冷却",author:"甜梦演示室",resolved:1b,pages:[{"text":"1 / 7   施法，魔力和冷却\n\n","color":"dark_aqua","bold":true,"extra":[{"text":"魔力是大部分武器或装备用来使用技能或打出伤害的资源。\n大部分剑和斧都是通过右键来使用技能，法杖通常潜行右键来使用技能，而弩通常射击即可触发技能。\n大部分技能都有冷却，技能需要等待冷却结束才可使用。","color":"black","bold":false}]}]}}}}
function sweetdream_floor:tutorial/stage/actor
function sweetdream_floor:tutorial/stage/mob
item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.offhand with minecraft:recovery_compass[minecraft:item_model="sweetdream:look"]
item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark"]
