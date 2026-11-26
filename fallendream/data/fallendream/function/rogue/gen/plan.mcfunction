scoreboard players set #rd_count zx.meta 1
function fallendream:rogue/gen/grow
execute store result score #rd_extra zx.meta run random value 1..4 fallendream:rogue
function fallendream:rogue/gen/extra
data modify storage zx:rogue floor.cells[10].dist set value 0
scoreboard players set #rd_round zx.meta 16
function fallendream:rogue/gen/relax
function fallendream:rogue/gen/boss
function fallendream:rogue/gen/assign
function fallendream:rogue/map/flags
