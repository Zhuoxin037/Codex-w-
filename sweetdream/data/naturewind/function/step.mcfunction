scoreboard players set #clock nw.anim 0
scoreboard players add #frame nw.anim 1
execute if score #frame nw.anim matches 16.. run scoreboard players set #frame nw.anim 0
execute as @a unless entity @s[tag=test_pending_return] if items entity @s weapon.mainhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.mainhand naturewind:animation_frame
execute as @a unless entity @s[tag=test_pending_return] if items entity @s weapon.offhand minecraft:recovery_compass[minecraft:item_model="naturewind:staff"] run item modify entity @s weapon.offhand naturewind:animation_frame
