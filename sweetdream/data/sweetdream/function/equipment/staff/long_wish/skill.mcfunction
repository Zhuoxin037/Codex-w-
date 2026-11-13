# 长愿 主动: 500 魔力 / 80 秒冷却。
# 召唤一个术阵 + 在自身位置生成半径 8 格、持续 16 秒(320 刻)的领域 marker。
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:long_wish",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:long_wish",cooldown_seconds:80.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:long_wish",type:"long_wish",duration_seconds:16.0,data:{radius:8.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create
data modify storage zx:work lw set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work lw.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work lw.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work lw.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work lw.u3 int 1 run scoreboard players get @s manacore.u3
execute at @s run function sweetdream:equipment/staff/long_wish/field_spawn with storage zx:work lw
playsound minecraft:block.beacon.activate player @s ~ ~ ~ 0.8 1.2
