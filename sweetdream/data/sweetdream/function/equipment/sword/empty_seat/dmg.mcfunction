# ============================================================
# sweetdream:equipment/sword/empty_seat/dmg —— 前方单目标：固定伤害 + 虚弱Ⅱ
# ------------------------------------------------------------
# @s = 目标。伤害 = #es_d（cast 里算好的 6×占位数），绕开 api/damage/calc。
# ============================================================
data modify storage zx:work a set value {fixed:1b,target:"@s",type:"minecraft:player_attack"}
data modify storage zx:work a.num set value 0.0
execute store result storage zx:work a.num double 1.0 run scoreboard players get #es_d zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work es.u0
data modify storage zx:work a.u1 set from storage zx:work es.u1
data modify storage zx:work a.u2 set from storage zx:work es.u2
data modify storage zx:work a.u3 set from storage zx:work es.u3
function sweetdream:internal/damage/with_from with storage zx:work a

effect give @s minecraft:weakness 5 1 true

execute at @s run particle minecraft:enchant ~ ~1 ~ 0.4 0.5 0.4 0.4 12 normal
execute at @s run particle minecraft:dust{color:[0.55,0.55,0.62],scale:1.2} ~ ~1 ~ 0.4 0.5 0.4 0.02 10 normal
