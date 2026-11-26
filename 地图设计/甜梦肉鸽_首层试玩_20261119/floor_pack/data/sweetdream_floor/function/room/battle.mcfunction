execute unless score #input sd.floor matches 20..21 run return 0
function sweetdream_floor:combat/count_weapons
execute if score #weapons sd.floor matches 4.. run return run tellraw @s {"text":"最多携带三把武器。回入口寄存，或在本房中部用 [打开寄存]。","color":"yellow"}
function sweetdream_floor:room/mark with storage sweetdream_floor:run inspected
function sweetdream_floor:combat/begin
