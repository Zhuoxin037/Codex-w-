function sweetdream:equipment/armor/late_dusk/watch
# Remove this instance's reference before damage can recursively open another one.
scoreboard players remove @s zx.lr_live 1
scoreboard players operation #lr_total zx.meta = @s zx.lr_sum
$scoreboard players remove #lr_total zx.meta $(base)
execute if score #lr_total zx.meta matches ..0 run scoreboard players set #lr_total zx.meta 0
# Freeze the amount/owner before label-consumption hooks can run.
execute unless data storage zx:work lr_settle_stack run data modify storage zx:work lr_settle_stack set value []
$data modify storage zx:work lr_settle_stack append value {amount:0,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute store result storage zx:work lr_settle_stack[-1].amount int 1 run scoreboard players get #lr_total zx.meta
data modify storage zx:work lr_settle_stack[-1].pct set value 30
execute if entity @s[tag=zx.status.dream] run data modify storage zx:work lr_settle_stack[-1].pct set value 50
execute if entity @s[tag=zx.status.dream] run function sweetdream:equipment/armor/late_dusk/consume_dream with storage zx:work lr_settle_stack[-1]
function sweetdream:equipment/armor/late_dusk/settle_damage with storage zx:work lr_settle_stack[-1]
data remove storage zx:work lr_settle_stack[-1]
execute unless score @s zx.lr_live matches 1.. run tag @s remove zx.lr_watch
