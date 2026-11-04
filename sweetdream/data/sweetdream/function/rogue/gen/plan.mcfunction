scoreboard players set #rd_count zx.meta 1
function sweetdream:rogue/gen/grow
execute store result score #rd_extra zx.meta run random value 1..4 sweetdream:rogue
function sweetdream:rogue/gen/extra
data modify storage zx:rogue floor.cells[10].dist set value 0
scoreboard players set #rd_round zx.meta 16
function sweetdream:rogue/gen/relax
function sweetdream:rogue/gen/boss
function sweetdream:rogue/gen/assign
function sweetdream:rogue/map/flags
