execute if entity @s[tag=zx.rg_prep] run function sweetdream:rogue/prep/restore_off
tag @s remove zx.rg_prep
tag @s remove zx.rg_wait
tag @s remove zx.rg_active
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage zx:work rg set value {}
data modify storage zx:work rg.uuid set from storage zx:data self.uuid
function sweetdream:rogue/prototype/home_dispatch with storage zx:work rg
execute at @s run function sweetdream:rogue/map/release
function sweetdream:rogue/prototype/maybe_unload
tellraw @s {"text":"已退出；再次进入会重新生成一层。","color":"gray"}
