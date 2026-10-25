function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
execute if score @s zx.wb_t <= #now manacore.meta run return run function sweetdream:equipment/sword/way_back/end

# 超限分流(2026-10-23 批 K3): 敲过超限石(ol:"way_back")的归途, "回来"这一下换成
#   「超限·归途」: 返还 100%(且无 40% 上限) + 10 秒迅捷Ⅱ + 5 秒抗性Ⅲ
#   + 对"原位置 → 灯"连线上的生物打一发 = 本次实际回复量的真伤。
# ★ 只在**第二段**(回来)分流 ★ 第一段(放灯)逐字不变 —— 文案的超限段只描述了"再次使用"。
# ★ 主副手都判, 且判 ol 的**值**是不是 way_back(照 liuguang/cast ⓪.5 那一课)。
scoreboard players set #wb_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["way_back"],ol:"way_back"}] run scoreboard players set #wb_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["way_back"],ol:"way_back"}] run scoreboard players set #wb_ol zx.meta 1
execute if score #wb_ol zx.meta matches 1 run return run function sweetdream:equipment/sword/way_back/ol_back

function sweetdream:equipment/sword/way_back/low_now
data modify storage zx:work owner_arg set from storage zx:data self
return run function sweetdream:equipment/sword/way_back/back_go with storage zx:work owner_arg
