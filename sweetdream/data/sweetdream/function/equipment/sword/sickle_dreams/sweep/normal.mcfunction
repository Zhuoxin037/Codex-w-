# 每刻只选一帧；所有帧复用同一个几何父模型。
execute if score @s zx.sd_t matches 1 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n01"}}
execute if score @s zx.sd_t matches 2 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n02"}}
execute if score @s zx.sd_t matches 3 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n03"}}
execute if score @s zx.sd_t matches 3 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/n03 with storage zx:sweep current
execute if score @s zx.sd_t matches 4 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n04"}}
execute if score @s zx.sd_t matches 4 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/n04 with storage zx:sweep current
execute if score @s zx.sd_t matches 5 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n05"}}
execute if score @s zx.sd_t matches 5 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/n05 with storage zx:sweep current
execute if score @s zx.sd_t matches 5 run function sweetdream:equipment/sword/sickle_dreams/sweep/at_impact with storage zx:sweep current
execute if score @s zx.sd_t matches 6 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n06"}}
execute if score @s zx.sd_t matches 7 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n07"}}
execute if score @s zx.sd_t matches 8 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n08"}}
execute if score @s zx.sd_t matches 9 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n09"}}
execute if score @s zx.sd_t matches 10 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n10"}}
execute if score @s zx.sd_t matches 11 run item modify entity @s weapon.mainhand {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n11"}}
execute if score @s zx.sd_t matches 12.. run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
