data merge block -100 90 46 {Page:0,Book:{id:"minecraft:written_book",count:1,components:{"minecraft:written_book_content":{title:"2. 五个通用标签",author:"甜梦演示室",resolved:1b,pages:[{"text":"2 / 7   五个通用标签\n\n","color":"dark_aqua","bold":true,"extra":[{"text":"流火、夜火、渊海、噬心、白昼梦为通用标签，相互可以共存。\n同名标签表示装备会施加、消耗或利用该状态。\n状态通常会在怪头顶（装备的标签也会在怪头顶）。","color":"black","bold":false}]}]}}}}
function sweetdream_floor:tutorial/stage/actor
function sweetdream_floor:tutorial/stage/mob
item replace entity @e[type=minecraft:armor_stand,tag=sd.edu_hero,distance=..25,limit=1] weapon.mainhand with minecraft:iron_sword[minecraft:item_model="sweetdream:tidemark"]
