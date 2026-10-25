# 每秒、@s=逻辑 marker。攻击仍以主人为中心，并且不消耗魔力。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run function sweetdream:equipment/tool/everlit/wisp_gone
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless items entity @a[tag=zx.ub,distance=0..,limit=1] weapon.offhand *[minecraft:custom_data~{zx:["everlit"]}] run return run function sweetdream:equipment/tool/everlit/wisp_gone
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute if entity @a[tag=zx.ub,tag=zx.el_seen,distance=0..,limit=1] run return run function sweetdream:equipment/tool/everlit/wisp_gone
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
tag @a[tag=zx.ub,distance=0..,limit=1] add zx.el_seen
tag @a[tag=zx.el_own] remove zx.el_own
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
tag @a[tag=zx.ub,distance=0..,limit=1] add zx.el_own
function sweetdream:equipment/tool/everlit/visual/ensure
# 不再tp乘客 marker，否则会让它从唯一显示载体上下车。
scoreboard players remove @s zx.el_cd 1
scoreboard players set #el_hit zx.meta 0
execute if score @s zx.el_cd matches ..0 store result score #el_hit zx.meta as @a[tag=zx.el_own,limit=1] at @s run function sweetdream:equipment/tool/everlit/strike
execute if score #el_hit zx.meta matches 1 run function sweetdream:equipment/tool/everlit/visual/attack
execute if score @s zx.el_cd matches ..0 run scoreboard players set @s zx.el_cd 2
