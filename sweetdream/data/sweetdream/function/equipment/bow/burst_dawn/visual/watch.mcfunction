# @s 玩家；只有手持/技能持续/退场时才进较重的 UUID 和装饰更新。
scoreboard players set #bv_held zx.meta 0
execute if items entity @s weapon.mainhand *[custom_data~{zx:["burst_dawn"]}] run scoreboard players set #bv_held zx.meta 1
execute if items entity @s weapon.offhand *[custom_data~{zx:["burst_dawn"]}] run scoreboard players set #bv_held zx.meta 1
execute if entity @s[nbt={Health:0.0f}] run scoreboard players set #bv_held zx.meta 0
execute unless score #bv_held zx.meta matches 1 unless score @s zx.bd_on matches 1 unless score @s zx.bv_back matches 1.. unless entity @s[tag=zx.bv_wearing] run return 0
data modify storage zx:work bvk set value {uuid:""}
function manacore:api/player/self_uuid
execute unless data storage manacore:out r.uuid run return 0
data modify storage zx:work bvk.uuid set from storage manacore:out r.uuid
execute if data storage zx:work bvk{uuid:""} run return 0
execute store result storage zx:work bvk.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work bvk.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work bvk.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work bvk.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/burst_dawn/visual/owned with storage zx:work bvk
