scoreboard players set @s bs.vclip 0
execute if score @s bs.state matches 0 if score @s bs.dir matches 1 run scoreboard players set @s bs.vclip 1
execute if score @s bs.state matches 0 if score @s bs.dir matches -1 run scoreboard players set @s bs.vclip 5
execute unless score @s bs.state matches 0 run scoreboard players operation @s bs.vclip = @s bs.state
execute if score @s bs.vclip = @s bs.oldclip run scoreboard players add @s bs.vframe 1
execute unless score @s bs.vclip = @s bs.oldclip run scoreboard players set @s bs.vframe 0
execute unless score @s bs.state matches 0 run scoreboard players operation @s bs.vframe = @s bs.age
execute if score @s bs.vclip matches 0 if score @s bs.vframe matches 60.. run scoreboard players set @s bs.vframe 0
execute if score @s bs.vclip matches 1 if score @s bs.vframe matches 24.. run scoreboard players set @s bs.vframe 0
execute if score @s bs.vclip matches 5 if score @s bs.vframe matches 24.. run scoreboard players set @s bs.vframe 0
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
execute unless score @s bs.vclip = @s bs.oldclip run scoreboard players set @s bs.vframe 0
function fallendream:boss/b_staff/visual/sync with storage fallendream:b_staff args
execute if score @s bs.vclip matches 0 run function fallendream:boss/b_staff/visual/clips/idle
execute if score @s bs.vclip matches 1 run function fallendream:boss/b_staff/visual/clips/walk
execute if score @s bs.vclip matches 2 run function fallendream:boss/b_staff/visual/clips/spawn
execute if score @s bs.vclip matches 3 run function fallendream:boss/b_staff/visual/clips/hurt
execute if score @s bs.vclip matches 4 run function fallendream:boss/b_staff/visual/clips/death
execute if score @s bs.vclip matches 5 run function fallendream:boss/b_staff/visual/clips/walk_back
execute if score @s bs.vclip matches 16 run function fallendream:boss/b_staff/visual/clips/repel_guard
execute if score @s bs.vclip matches 10 run function fallendream:boss/b_staff/visual/clips/cast_three
execute if score @s bs.vclip matches 11 run function fallendream:boss/b_staff/visual/clips/fan_volley
execute if score @s bs.vclip matches 12 run function fallendream:boss/b_staff/visual/clips/mark_ground
execute if score @s bs.vclip matches 13 run function fallendream:boss/b_staff/visual/clips/ring_wave
execute if score @s bs.vclip matches 14 run function fallendream:boss/b_staff/visual/clips/repel_retreat
execute if score @s bs.vclip matches 15 run function fallendream:boss/b_staff/visual/clips/scatter_cross
scoreboard players operation @s bs.oldclip = @s bs.vclip
