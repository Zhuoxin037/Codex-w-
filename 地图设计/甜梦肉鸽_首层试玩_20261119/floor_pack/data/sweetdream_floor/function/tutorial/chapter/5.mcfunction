data merge block -100 90 46 {Page:0,Book:{id:"minecraft:written_book",count:1,components:{"minecraft:written_book_content":{title:"5. 属性与伤害标签",author:"甜梦演示室",resolved:1b,pages:[{"text":"5 / 7   属性与伤害标签\n\n","color":"dark_aqua","bold":true,"extra":[{"text":"当前魔力看当前剩余的魔力。最大魔力看上限。\n基础攻击、生命上限对应各自的属性。\n固定伤害跳过常规伤害增幅。\n真实伤害不会受到生物的护甲值而减少。","color":"black","bold":false}]}]}}}}
function sweetdream_floor:tutorial/stage/actor
function sweetdream_floor:tutorial/stage/mob
item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark"]
