function fallendream:boss/b_staff/fx/new {model:"bolt",kind:3}
tp @e[tag=sd.bs.newfx,distance=0..,limit=1] ~ ~ ~ ~ ~
scoreboard players set @e[tag=sd.bs.newfx,distance=0..,limit=1] bs.life 50
tag @e[tag=sd.bs.newfx,distance=0..] remove sd.bs.newfx
