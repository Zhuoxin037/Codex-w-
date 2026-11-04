$data modify storage zx:rogue floor.cells[$(cell)].kind set value "$(kind)"
$data modify storage zx:rogue floor.cells[$(cell)].variant set value $(variant)
$scoreboard players add #rd_k_$(kind) zx.meta 1
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"elite"}] run data modify storage zx:rogue floor.cells[$(cell)].radius set value 10
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"merchant"}] run scoreboard players add #rd_commerce zx.meta 1
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"rental"}] run scoreboard players add #rd_commerce zx.meta 1
$execute if data storage zx:rogue floor.cells[{cell:$(cell),kind:"blackmarket"}] run scoreboard players add #rd_commerce zx.meta 1
