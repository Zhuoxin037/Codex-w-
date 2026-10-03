# ============================================================
# sweetdream:equipment/sword/sickle_dreams/sweep/heavy —— 强化横扫的逐帧动画
# ------------------------------------------------------------
# 【宏参数】zx:sweep current {…, hand}   hand = weapon.mainhand / weapon.offhand
# 【和 normal 同一套写法】只是帧更多、时长更长。$(hand) 见 normal 顶部说明。
# 【含 $(hand) 的行必须以 $ 开头】漏了就整个函数加载失败(普通函数"加载失败",
#   宏函数"一条都不跑"), 改这批文件时最容易栽在这一条上。
# ============================================================

$execute if score @s zx.sd_t matches 1 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h01"}}
$execute if score @s zx.sd_t matches 2 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h02"}}
execute if score @s zx.sd_t matches 2 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h02 with storage zx:sweep current
$execute if score @s zx.sd_t matches 3 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h03"}}
execute if score @s zx.sd_t matches 3 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h03 with storage zx:sweep current
$execute if score @s zx.sd_t matches 4 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h04"}}
execute if score @s zx.sd_t matches 4 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h04 with storage zx:sweep current
$execute if score @s zx.sd_t matches 5 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h05"}}
execute if score @s zx.sd_t matches 5 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h05 with storage zx:sweep current
$execute if score @s zx.sd_t matches 6 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h06"}}
$execute if score @s zx.sd_t matches 7 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h07"}}
execute if score @s zx.sd_t matches 7 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h07 with storage zx:sweep current
$execute if score @s zx.sd_t matches 8 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h08"}}
execute if score @s zx.sd_t matches 8 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h08 with storage zx:sweep current
$execute if score @s zx.sd_t matches 9 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h09"}}
execute if score @s zx.sd_t matches 9 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h09 with storage zx:sweep current
execute if score @s zx.sd_t matches 9 run function sweetdream:equipment/sword/sickle_dreams/sweep/at_impact with storage zx:sweep current
$execute if score @s zx.sd_t matches 10 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h10"}}
execute if score @s zx.sd_t matches 10 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h10 with storage zx:sweep current
$execute if score @s zx.sd_t matches 11 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h11"}}
execute if score @s zx.sd_t matches 11 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h11 with storage zx:sweep current
$execute if score @s zx.sd_t matches 12 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h12"}}
execute if score @s zx.sd_t matches 12 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h12 with storage zx:sweep current
$execute if score @s zx.sd_t matches 13 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h13"}}
execute if score @s zx.sd_t matches 13 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/h13 with storage zx:sweep current
$execute if score @s zx.sd_t matches 14 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h14"}}
$execute if score @s zx.sd_t matches 15 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h15"}}
$execute if score @s zx.sd_t matches 16 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h16"}}
$execute if score @s zx.sd_t matches 17 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h17"}}
$execute if score @s zx.sd_t matches 18 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h18"}}
$execute if score @s zx.sd_t matches 19 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h19"}}
$execute if score @s zx.sd_t matches 20 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h20"}}
$execute if score @s zx.sd_t matches 21 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h21"}}
$execute if score @s zx.sd_t matches 22 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h22"}}
$execute if score @s zx.sd_t matches 23 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/h23"}}
execute if score @s zx.sd_t matches 24.. run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
