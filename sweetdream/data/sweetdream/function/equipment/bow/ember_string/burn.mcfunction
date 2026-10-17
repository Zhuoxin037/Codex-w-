# ============================================================
# sweetdream:equipment/bow/ember_string/burn —— 分支③: 对已带「夜火」的目标补一份伤害
# ------------------------------------------------------------
# 【执行者】被命中那只生物(由 fire 用 as/at 送进来)
# 【入参】zx:work es {dmg, u0..u3}
# 【为什么单独一个文件】伤害要带"射手归属"(u0..u3 拼选择器), 而那段是宏;
#   拆出来之后 fire 的三条分支读起来是一条线。
# ============================================================

# 表现: 夜火被"再点一把"的爆燃
execute at @s run particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.03 10 normal
execute at @s run particle minecraft:soul_fire_flame ~ ~1 ~ 0.25 0.35 0.25 0.01 5 normal

data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work es.dmg
data modify storage zx:work a.u0 set from storage zx:work es.u0
data modify storage zx:work a.u1 set from storage zx:work es.u1
data modify storage zx:work a.u2 set from storage zx:work es.u2
data modify storage zx:work a.u3 set from storage zx:work es.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
