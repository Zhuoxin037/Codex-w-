tag @s remove sd.bs.newbody
scoreboard players set @s bs.state 2
scoreboard players set @s bs.age 0
scoreboard players set @s bs.vclip 2
scoreboard players set @s bs.vframe 0
scoreboard players set @s bs.oldclip -1
scoreboard players set @s bs.oldframe -1
scoreboard players set @s bs.lastHP 600000
scoreboard players set @s bs.clock 0
scoreboard players set @s bs.rest 0
scoreboard players set @s bs.near 0
scoreboard players set @s bs.turn 0
scoreboard players set @s bs.last -1
scoreboard players set @s bs.cd 0
scoreboard players set @s bs.bar 0
scoreboard players set @s bs.freeze 0
scoreboard players set @s bs.oldyaw -999999
scoreboard players set @s bs.wait 20
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/bar/create with storage fallendream:b_staff args
function fallendream:boss/b_staff/visual/update
