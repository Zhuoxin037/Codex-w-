# ============================================================
# sweetdream:equipment/bow/dark_sun/strike —— 打出「黯日」主目标那一段额外伤害
# ------------------------------------------------------------
# 【执行者】被命中那只生物(由 fire 用 as/at 送进来)
# 【入参】zx:work ds {dmg, u0..u3}
# ============================================================

execute at @s run particle minecraft:damage_indicator ~ ~1 ~ 0.35 0.5 0.35 0.03 10 normal
execute at @s run particle minecraft:soul ~ ~1 ~ 0.25 0.4 0.25 0.02 8 normal
execute at @s run particle minecraft:dust{color:[0.45,0.18,0.62],scale:1.2} ~ ~1 ~ 0.3 0.4 0.3 0.0 8 normal

data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work ds.dmg
data modify storage zx:work a.u0 set from storage zx:work ds.u0
data modify storage zx:work a.u1 set from storage zx:work ds.u1
data modify storage zx:work a.u2 set from storage zx:work ds.u2
data modify storage zx:work a.u3 set from storage zx:work ds.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
