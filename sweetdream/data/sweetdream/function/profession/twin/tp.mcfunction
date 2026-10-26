data modify storage zx:work jtp set value {dim:"minecraft:overworld",x:0.0,y:64.0,z:0.0}
$data modify storage zx:work jtp.dim set value "$(dim)"
data modify storage zx:work jtp.x set from storage zx:work jt_dest.pos[0]
data modify storage zx:work jtp.y set from storage zx:work jt_dest.pos[1]
data modify storage zx:work jtp.z set from storage zx:work jt_dest.pos[2]
function sweetdream:profession/twin/tp_go with storage zx:work jtp
