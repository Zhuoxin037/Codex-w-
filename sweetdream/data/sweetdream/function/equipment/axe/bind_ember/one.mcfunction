# ============================================================
# sweetdream:equipment/axe/bind_ember/one —— 扇形单目标结算（@s = 目标）
# ------------------------------------------------------------
# 顺序很重要：**先判有没有流火（判"新获得"），再施加**。
# 反了的话人人都是"新获得"，一次扇形能白减 5 秒冷却。
# ============================================================
execute unless entity @s[tag=zx.status.liuhuo] run scoreboard players add #be_new zx.meta 1

function sweetdream:tag/mark {target:"@s",mark:"liuhuo"}
effect give @s minecraft:slowness 3 1 true

data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack"}
data modify storage zx:work a.num set from storage zx:work be.dmg
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work be.u0
data modify storage zx:work a.u1 set from storage zx:work be.u1
data modify storage zx:work a.u2 set from storage zx:work be.u2
data modify storage zx:work a.u3 set from storage zx:work be.u3
function sweetdream:internal/damage/with_from with storage zx:work a

execute at @s run particle minecraft:flame ~ ~1 ~ 0.35 0.4 0.35 0.01 10 normal
execute at @s run particle minecraft:lava ~ ~1 ~ 0.25 0.3 0.25 0 4 normal
