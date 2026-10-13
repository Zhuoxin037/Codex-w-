# @s = 已被命中的活体; 一只实体一份观察 marker, 后续攻击刷新归属与 110 刻窗口。
# UUID 只格式化一次。不能用死亡后 @e[nbt={UUID:...}] 来追踪。
data modify storage zx:sr watch set value {victim:"",u0:0,u1:0,u2:0,u3:0}
execute on attacker run data modify storage zx:sr watch.u0 set from entity @s UUID[0]
execute on attacker run data modify storage zx:sr watch.u1 set from entity @s UUID[1]
execute on attacker run data modify storage zx:sr watch.u2 set from entity @s UUID[2]
execute on attacker run data modify storage zx:sr watch.u3 set from entity @s UUID[3]
function sweetdream:equipment/axe/sacred_relic/victim_uuid
function sweetdream:equipment/axe/sacred_relic/observe_bind with storage zx:sr watch
