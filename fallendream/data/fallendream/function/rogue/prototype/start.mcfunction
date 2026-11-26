execute if entity @s[tag=zx.rg_active] run return 0
execute if entity @s[tag=zx.rg_wait] run return 0
execute if entity @s[tag=zx.rg_prep] run return 0
execute unless entity @s[type=minecraft:player] run return 0
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rg set value {}
data modify storage zx:work rg.uuid set from storage zx:data self.uuid
function fallendream:rogue/prototype/save_home with storage zx:work rg
scoreboard players set #rd_new zx.meta 0
execute unless entity @a[tag=zx.rg_active] unless entity @a[tag=zx.rg_wait] unless entity @a[tag=zx.rg_prep] run scoreboard players set #rd_new zx.meta 1
tag @s add zx.rg_wait
execute if score #rd_new zx.meta matches 1 run function fallendream:rogue/gen/request
tellraw @s {"text":"正在生成本层房间与地图……","color":"aqua"}
