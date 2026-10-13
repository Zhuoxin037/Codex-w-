# 真正的 player_killed_entity 奖励, @s = 击杀者。只查该玩家的准确受害者记录。
# 没有最近受害者/邻近尸体兜底, 也没有玩家同刻去重。
advancement revoke @s only sweetdream:equipment/axe/sacred_relic_kill
scoreboard players add #sr_s1 zx.meta 1
function sweetdream:equipment/axe/sacred_relic/held
execute unless score #sr_held zx.meta matches 1 run return 0
scoreboard players add #sr_s2 zx.meta 1
data modify storage zx:sr killer set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:sr killer.u0 set from entity @s UUID[0]
data modify storage zx:sr killer.u1 set from entity @s UUID[1]
data modify storage zx:sr killer.u2 set from entity @s UUID[2]
data modify storage zx:sr killer.u3 set from entity @s UUID[3]
function sweetdream:equipment/axe/sacred_relic/kill_scan with storage zx:sr killer
