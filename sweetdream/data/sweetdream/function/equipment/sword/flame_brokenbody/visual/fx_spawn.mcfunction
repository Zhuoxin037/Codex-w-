# 一个 UUID 最多一个短时焰刃；用载体物品custom_data保留元数据，不写Display不支持的根data。
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:fbvis clear set value {uuid:""}
data modify storage zx:fbvis clear.uuid set from storage zx:data self.uuid
function sweetdream:equipment/sword/flame_brokenbody/visual/clear_owned with storage zx:fbvis clear
data modify storage zx:fbvis owner set value {uuid:"",u0:0,u1:0,u2:0,u3:0,yaw:0.0f}
data modify storage zx:fbvis owner.uuid set from storage zx:data self.uuid
data modify storage zx:fbvis owner.u0 set from entity @s UUID[0]
data modify storage zx:fbvis owner.u1 set from entity @s UUID[1]
data modify storage zx:fbvis owner.u2 set from entity @s UUID[2]
data modify storage zx:fbvis owner.u3 set from entity @s UUID[3]
data modify storage zx:fbvis owner.yaw set from entity @s Rotation[0]
function sweetdream:equipment/sword/flame_brokenbody/visual/fx_summon with storage zx:fbvis owner
