# Keep the room selected during preparation and combat, including movement skills.
$execute positioned $(minx) 78 $(minz) unless entity @s[dx=$(width),dy=19,dz=$(width)] run function sweetdream_floor:room/teleport_cell with storage sweetdream_floor:run encounter
$scoreboard players set @s zx.rg_room $(cell)
