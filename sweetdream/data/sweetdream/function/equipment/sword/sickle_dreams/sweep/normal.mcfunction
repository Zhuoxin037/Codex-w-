# ============================================================
# sweetdream:equipment/sword/sickle_dreams/sweep/normal —— 基础横扫的逐帧动画
# ------------------------------------------------------------
# 【宏参数】zx:sweep current {…, hand}   hand = weapon.mainhand / weapon.offhand
# 【每刻只选一帧】所有帧复用同一个几何父模型, 所以这里只是换 item_model。
# 【★ 副手支持 ★】整份文件里唯一"认手"的地方就是 $(hand) —— 挥的是哪只手里的
#   镰刀, 就改哪个槽位的模型。写死 weapon.mainhand 的话, 副手施法时动画会
#   落到主手那把(可能是别的武器)身上, 看着像"武器被换了"。
# 【含 $(hand) 的行必须以 $ 开头】这是宏替换的硬性要求, 漏了就整个函数加载失败。
# ============================================================

$execute if score @s zx.sd_t matches 1 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n01"}}
$execute if score @s zx.sd_t matches 2 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n02"}}
$execute if score @s zx.sd_t matches 3 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n03"}}
execute if score @s zx.sd_t matches 3 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/n03 with storage zx:sweep current
$execute if score @s zx.sd_t matches 4 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n04"}}
execute if score @s zx.sd_t matches 4 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/n04 with storage zx:sweep current
$execute if score @s zx.sd_t matches 5 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n05"}}
execute if score @s zx.sd_t matches 5 run function sweetdream:equipment/sword/sickle_dreams/sweep/fx_at/n05 with storage zx:sweep current
execute if score @s zx.sd_t matches 5 run function sweetdream:equipment/sword/sickle_dreams/sweep/at_impact with storage zx:sweep current
$execute if score @s zx.sd_t matches 6 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n06"}}
$execute if score @s zx.sd_t matches 7 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n07"}}
$execute if score @s zx.sd_t matches 8 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n08"}}
$execute if score @s zx.sd_t matches 9 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n09"}}
$execute if score @s zx.sd_t matches 10 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n10"}}
$execute if score @s zx.sd_t matches 11 run item modify entity @s $(hand) {function:"minecraft:set_components",components:{"minecraft:item_model":"dreamscythe:sweep/n11"}}
execute if score @s zx.sd_t matches 12.. run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
