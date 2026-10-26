function sweetdream:lib/uuid
data modify storage zx:work jchoice.uuid set from storage zx:data self.uuid
function sweetdream:profession/mage/choice_clean with storage zx:work jchoice
execute if score #jchosen zx.meta matches 1 run function sweetdream:profession/mage/p_pain
execute if score #jchosen zx.meta matches 2 run function sweetdream:profession/mage/p_sorrow
execute if score #jchosen zx.meta matches 3 run function sweetdream:profession/mage/p_shatter
execute if score #jchosen zx.meta matches 4 run function sweetdream:profession/mage/p_rebirth
execute if score #jchosen zx.meta matches 5 run function sweetdream:profession/mage/p_bloom
execute if score #jchosen zx.meta matches 1 run scoreboard players set #jbit zx.meta 1
execute if score #jchosen zx.meta matches 2 run scoreboard players set #jbit zx.meta 2
execute if score #jchosen zx.meta matches 3 run scoreboard players set #jbit zx.meta 4
execute if score #jchosen zx.meta matches 4 run scoreboard players set #jbit zx.meta 8
execute if score #jchosen zx.meta matches 5 run scoreboard players set #jbit zx.meta 16
scoreboard players operation #jhas zx.meta = @s zx.j_seen
scoreboard players operation #jhas zx.meta /= #jbit zx.meta
scoreboard players operation #jhas zx.meta %= #j2 zx.meta
execute if score #jhas zx.meta matches 0 run scoreboard players operation @s zx.j_seen += #jbit zx.meta
execute if score @s zx.j_seen matches 31 run function sweetdream:profession/mage/secret
