$execute unless block ^ ^0.1 ^$(step) #sweetdream:boss_passable run return run function sweetdream:boss/knight/shadow/end
$execute unless block ^ ^1.4 ^$(step) #sweetdream:boss_passable run return run function sweetdream:boss/knight/shadow/end
$execute unless block ^ ^2.8 ^$(step) #sweetdream:boss_passable run return run function sweetdream:boss/knight/shadow/end
$execute unless block ^ ^4.3 ^$(step) #sweetdream:boss_passable run return run function sweetdream:boss/knight/shadow/end
$tp @s ^ ^ ^$(step)
$execute at @s run function sweetdream:boss/knight/shadow/contact/$(frame) with storage sweetdream:knight shadow_args
