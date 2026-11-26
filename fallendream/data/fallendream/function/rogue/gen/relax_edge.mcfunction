$execute store result score #rd_da zx.meta run data get storage zx:rogue floor.cells[$(a)].dist
$execute store result score #rd_db zx.meta run data get storage zx:rogue floor.cells[$(b)].dist
scoreboard players add #rd_da zx.meta 1
$execute if score #rd_da zx.meta < #rd_db zx.meta store result storage zx:rogue floor.cells[$(b)].dist int 1 run scoreboard players get #rd_da zx.meta
scoreboard players remove #rd_da zx.meta 1
scoreboard players add #rd_db zx.meta 1
$execute if score #rd_db zx.meta < #rd_da zx.meta store result storage zx:rogue floor.cells[$(a)].dist int 1 run scoreboard players get #rd_db zx.meta
