data modify storage zx:work jboss_forget set value {kind:"",id:0}
execute if entity @s[tag=sd.fb.body] run data modify storage zx:work jboss_forget.kind set value "fireaxe"
execute if entity @s[tag=sd.fb.body] store result storage zx:work jboss_forget.id int 1 run scoreboard players get @s sdbf.id
execute if entity @s[tag=sd.kn.body] run data modify storage zx:work jboss_forget.kind set value "knight"
execute if entity @s[tag=sd.kn.body] store result storage zx:work jboss_forget.id int 1 run scoreboard players get @s sdk.id
execute if entity @s[tag=sd.hk.body] run data modify storage zx:work jboss_forget.kind set value "husk"
execute if entity @s[tag=sd.hk.body] store result storage zx:work jboss_forget.id int 1 run scoreboard players get @s sdh.id
function sweetdream:profession/twin/boss_forget_go with storage zx:work jboss_forget
