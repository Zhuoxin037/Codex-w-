$execute if data storage zx:work jboss_forget{kind:"fireaxe"} run data modify storage sweetdream:fireaxe targets."$(id)" set value {}
$execute if data storage zx:work jboss_forget{kind:"knight"} run data modify storage sweetdream:knight targets."$(id)" set value {}
$execute if data storage zx:work jboss_forget{kind:"husk"} run data modify storage sweetdream:husk targets."$(id)" set value {}
execute if data storage zx:work jboss_forget{kind:"fireaxe"} run tag @e[tag=sd.fb.target,distance=0..] remove sd.fb.target
execute if data storage zx:work jboss_forget{kind:"knight"} run tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
execute if data storage zx:work jboss_forget{kind:"husk"} run tag @e[tag=sd.hk.target,distance=0..] remove sd.hk.target
