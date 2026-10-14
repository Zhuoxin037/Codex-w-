execute if entity @s[tag=zx.av_cast] run function sweetdream:equipment/axe/anchor/visual/end

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:anchor key set value {uuid:""}
data modify storage zx:anchor key.uuid set from storage zx:data self.uuid

data modify storage zx:anchor new set value {uuid:"",u0:0,u1:0,u2:0,u3:0,t0:0,t1:0,t2:0,t3:0,dim:0}
data modify storage zx:anchor new.uuid set from storage zx:data self.uuid
data modify storage zx:anchor new.u0 set from entity @s UUID[0]
data modify storage zx:anchor new.t0 set from entity @e[tag=zx.an_tgt,distance=0..,limit=1] UUID[0]
data modify storage zx:anchor new.u1 set from entity @s UUID[1]
data modify storage zx:anchor new.t1 set from entity @e[tag=zx.an_tgt,distance=0..,limit=1] UUID[1]
data modify storage zx:anchor new.u2 set from entity @s UUID[2]
data modify storage zx:anchor new.t2 set from entity @e[tag=zx.an_tgt,distance=0..,limit=1] UUID[2]
data modify storage zx:anchor new.u3 set from entity @s UUID[3]
data modify storage zx:anchor new.t3 set from entity @e[tag=zx.an_tgt,distance=0..,limit=1] UUID[3]

function sweetdream:equipment/axe/anchor/visual/remember_hand
execute store result storage zx:anchor new.dim int 1 run scoreboard players get @s zx.av_dim
scoreboard players set @s zx.av_phase 0
scoreboard players set @s zx.av_t 0
execute unless entity @s[tag=test_pending_return] run function sweetdream:equipment/axe/anchor/visual/hide
function sweetdream:equipment/axe/anchor/visual/start_owner with storage zx:anchor new
tag @e[tag=zx.an_tgt,distance=0..] remove zx.an_tgt
