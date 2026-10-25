# Called every tick even after unequipping. Initialize existing white on migration.
execute if score @s zx.gl_r matches 1 if score @s zx.gl_g matches 1 if score @s zx.gl_y matches 1 unless score @s zx.gl_wt matches 1.. run function sweetdream:equipment/armor/glimmer/white_start
execute if score @s zx.gl_wt matches 1.. if score @s zx.gl_wt <= #now manacore.meta run function sweetdream:equipment/armor/glimmer/clear
