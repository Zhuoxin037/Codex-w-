execute unless items entity @s hotbar.* *[custom_data~{zx:["dream_waker"]}] unless items entity @s inventory.* *[custom_data~{zx:["dream_waker"]}] unless items entity @s weapon.offhand *[custom_data~{zx:["dream_waker"]}] run return 0
function sweetdream:profession/ensure
data modify storage zx:work dw_lore set value {job:0}
execute if score @s zx.job matches 0..4 store result storage zx:work dw_lore.job int 1 run scoreboard players get @s zx.job
function sweetdream:equipment/tool/dream_waker/sync_slots with storage zx:work dw_lore
