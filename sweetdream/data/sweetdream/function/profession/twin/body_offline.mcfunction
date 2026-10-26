data modify storage zx:work jt_offline set from entity @s data
data modify storage zx:work jt_offline.hp set from entity @s Health
function sweetdream:profession/twin/body_offline_go with storage zx:work jt_offline
kill @s
