# Moving to the unused preview dimension untracks the actors before death.
$tag $(actors) add sd.edu_discard
$execute as $(actors) in sweetdream:rogue_preview run tp @s 0 -60 0
execute in sweetdream:rogue_preview positioned 0 -60 0 run kill @e[tag=sd.edu_discard,distance=..2]
