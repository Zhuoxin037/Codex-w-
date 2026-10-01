# ============================================================
# sweetdream:overlimit/api/bonus_held —— 主手武器"敲没敲过超限" + 它的数值
# ------------------------------------------------------------
# 【出参】zx:out r = {has:1b/0b, of:"<武器id>", dmg:.., mana:.., cd:..}
# 【武器怎么用】和升级一样相乘即可; 更独有的效果写在武器自己的超限钩子里。
# 【没敲过】has=0 且三个乘区都是 0, 武器代码可以无脑乘, 不会有副作用。
# ============================================================

data modify storage zx:out r set value {has:0b,of:"",dmg:0.0,mana:0.0,cd:0.0}
execute unless data entity @s SelectedItem.components."minecraft:custom_data".ol run return 0
data modify storage zx:out r.has set value 1b
data modify storage zx:out r.of set from entity @s SelectedItem.components."minecraft:custom_data".ol
data modify storage zx:work ol.of set from entity @s SelectedItem.components."minecraft:custom_data".ol
function sweetdream:overlimit/api/bonus_of with storage zx:work ol