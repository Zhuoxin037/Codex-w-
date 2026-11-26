advancement revoke @s only fallendream:profession/twin_saved
execute unless score @s zx.job matches 4 run return 0
execute unless score @s zx.j_form matches 1 run return 0
function fallendream:profession/twin/record
function fallendream:profession/twin/guard_restore with storage zx:work jt
function fallendream:profession/twin/died
