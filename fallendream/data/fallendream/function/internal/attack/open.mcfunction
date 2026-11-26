data modify storage zx:combat events append value {event:{}}
data modify storage zx:combat events[-1].event set from storage zx:combat input
execute store result storage zx:combat events[-1].event.old_charge int 1 run scoreboard players get @s zx.atk_ok
data modify storage zx:combat events[-1].event.owns_chain set value 0b
execute unless data storage zx:combat events[-1].event{kind:"melee"} run scoreboard players set @s zx.atk_ok 1
execute if score @s zx.mi_armed matches 1 if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["mana_imbue"],ol:"mana_imbue"}] run function fallendream:internal/attack/chain_open
execute if score @s zx.bf_rdy matches 1 run data modify storage zx:combat events[-1].event.was.borrow_fire set value 1b
function fallendream:internal/attack/chain_credit_event with storage zx:combat events[-1].event
