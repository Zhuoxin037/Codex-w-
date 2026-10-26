tag @s remove sd.hk.new
data modify entity @s Rotation set from entity @e[tag=sd.hk.current_rig,distance=0..,limit=1] Rotation
scoreboard players set @s sdh.state 0
scoreboard players set @s sdh.age 0
scoreboard players set @s sdh.rest 20
scoreboard players set @s sdh.defcd 80
scoreboard players set @s sdh.pending_cd 0
scoreboard players set @s sdh.lastdef 1
scoreboard players set @s sdh.fall 0
scoreboard players set @s sdh.blocked 0
scoreboard players set @s sdh.prev_hp 1000000
scoreboard players set @s sdh.target_hp 1000000
scoreboard players set @s sdh.energy 0
scoreboard players set @s sdh.flash 0
scoreboard players set @s sdh.hit0 0
scoreboard players set @s sdh.hit1 0
scoreboard players set @s sdh.lastmove 0
function sweetdream:boss/husk/ward/normal
function sweetdream:boss/husk/resize
