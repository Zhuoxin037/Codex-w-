execute unless block ^ ^ ^0.2 #sweetdream:boss_passable run return run function sweetdream:boss/knight/wave/end
execute unless block ^1.1 ^ ^0.2 #sweetdream:boss_passable run return run function sweetdream:boss/knight/wave/end
execute unless block ^-1.1 ^ ^0.2 #sweetdream:boss_passable run return run function sweetdream:boss/knight/wave/end
execute unless block ^1.1 ^1.1 ^0.2 #sweetdream:boss_passable run return run function sweetdream:boss/knight/wave/end
execute unless block ^-1.1 ^1.1 ^0.2 #sweetdream:boss_passable run return run function sweetdream:boss/knight/wave/end
execute unless block ^1.1 ^-0.8 ^0.2 #sweetdream:boss_passable run return run function sweetdream:boss/knight/wave/end
execute unless block ^-1.1 ^-0.8 ^0.2 #sweetdream:boss_passable run return run function sweetdream:boss/knight/wave/end
tp @s ^ ^ ^0.2
execute at @s positioned ~-1.2 ~-1.5 ~-1.2 as @a[gamemode=!creative,gamemode=!spectator,dx=2.4,dy=3,dz=2.4] run function sweetdream:boss/knight/wave/hit
execute at @s positioned ~-1.2 ~-1.5 ~-1.2 as @e[tag=sd.kn.target,type=!minecraft:player,dx=2.4,dy=3,dz=2.4] run function sweetdream:boss/knight/wave/hit
execute if score @s sdk.echo matches 1 if score @s sdk.age matches 1.. at @s run function sweetdream:boss/knight/echo/record
