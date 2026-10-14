# @s=marker；原三维度每刻各一次扫描。下线/切维度/卸下/死亡及时清理。
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1] run return run function sweetdream:equipment/tool/everlit/wisp_gone
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},nbt={Health:0.0f},distance=0..,limit=1] run return run function sweetdream:equipment/tool/everlit/wisp_gone
$execute unless items entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..,limit=1] weapon.offhand *[minecraft:custom_data~{zx:["everlit"]}] run return run function sweetdream:equipment/tool/everlit/wisp_gone
function sweetdream:equipment/tool/everlit/visual/ensure
execute unless score @s zx.el_clock matches 0.. run function sweetdream:equipment/tool/everlit/visual/init
scoreboard players operation #el_mod zx.meta = @s zx.el_clock
scoreboard players operation #el_mod zx.meta %= #el_4 zx.meta
execute if score #el_mod zx.meta matches 0 run function sweetdream:equipment/tool/everlit/visual/read_mana with entity @s data.zx.el
execute if score @s zx.el_state matches 0 if score @s zx.el_mana matches ..199 run function sweetdream:equipment/tool/everlit/visual/start_dark
execute if score @s zx.el_state matches 2 if score @s zx.el_mana matches 200.. run function sweetdream:equipment/tool/everlit/visual/start_light
execute unless score @s zx.el_attack matches 0..22 run function sweetdream:equipment/tool/everlit/visual/follow with entity @s data.zx.el
execute if score @s zx.el_attack matches 0..22 run function sweetdream:equipment/tool/everlit/visual/follow_attack with entity @s data.zx.el
function sweetdream:equipment/tool/everlit/visual/frame
function sweetdream:equipment/tool/everlit/visual/advance
