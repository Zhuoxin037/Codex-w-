function fallendream:lib/uuid
# 倍率由 explode 按"常规 / 追踪 / 返回"选好塞进 zx:work ff.mul(默认 0.04 = 原版)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.04}
data modify storage manacore:in arg.other_mul set from storage zx:work ff.mul
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[tag=zx.ff_hit,distance=0..]",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
