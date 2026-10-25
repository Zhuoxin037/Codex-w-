# ============================================================
# sweetdream:equipment/sword/profane/one_plain —— 未带噬心：基础攻击力 ×5
# ============================================================
data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from storage zx:work pf.d5
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work pf.u0
data modify storage zx:work a.u1 set from storage zx:work pf.u1
data modify storage zx:work a.u2 set from storage zx:work pf.u2
data modify storage zx:work a.u3 set from storage zx:work pf.u3
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @s run particle minecraft:crit ~ ~1 ~ 0.3 0.4 0.3 0 8 normal
