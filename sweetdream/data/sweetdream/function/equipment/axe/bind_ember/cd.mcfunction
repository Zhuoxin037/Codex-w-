# 减少此玩家所有已声明技能的现存冷却记录。
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:bind_ember",seconds:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.seconds double 1.0 run scoreboard players get #be_new zx.meta
function sweetdream:equipment/staff/stop_needle/cd_all

execute at @s run particle minecraft:dust{color:[0.9,0.5,0.15],scale:0.9} ~ ~1 ~ 0.5 0.6 0.5 0.01 10 normal
