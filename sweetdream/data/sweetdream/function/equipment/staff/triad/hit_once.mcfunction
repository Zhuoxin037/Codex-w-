# ============================================================
# sweetdream:equipment/staff/triad/hit_once —— 补打一下(额外攻击的那两下)
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s)
# 【入参】storage zx:work tri {dmg, u0..u3} —— 由 hit_more 在切换执行者之前备好。
# 【伤害类型】跟随全包默认(zx:config damage_type, 一般是 sweetdream:skill);
#   与普攻那一发同源, 保证加成口径一致。
# ============================================================

data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work tri.dmg
data modify storage zx:work a.u0 set from storage zx:work tri.u0
data modify storage zx:work a.u1 set from storage zx:work tri.u1
data modify storage zx:work a.u2 set from storage zx:work tri.u2
data modify storage zx:work a.u3 set from storage zx:work tri.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
