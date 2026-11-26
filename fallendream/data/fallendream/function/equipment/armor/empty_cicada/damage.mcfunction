function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.06}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work a set value {target:"@e[type=!#fallendream:no_damage,distance=..3]",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_extra
# 普通版保持原6点；超限授盾由整次位移结束时统一给12点。
execute if data storage zx:work cic_pos{ol:1b} run return 0
scoreboard players set #s2_g_v zx.meta 6000
scoreboard players set #s2_g_t zx.meta 100
function fallendream:batch21/shield/grant
