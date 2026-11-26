$execute unless block ^ ^0.1 ^$(step) #fallendream:boss_passable run return run function fallendream:boss/knight/shadow/end
$execute unless block ^ ^1.4 ^$(step) #fallendream:boss_passable run return run function fallendream:boss/knight/shadow/end
$execute unless block ^ ^2.8 ^$(step) #fallendream:boss_passable run return run function fallendream:boss/knight/shadow/end
$execute unless block ^ ^4.3 ^$(step) #fallendream:boss_passable run return run function fallendream:boss/knight/shadow/end
$tp @s ^ ^ ^$(step)
$execute at @s run function fallendream:boss/knight/shadow/contact/$(frame) with storage fallendream:knight shadow_args
