# ============================================================
# sweetdream:equipment/bow/lucid_dream/big_dmg —— 大效果伤害结算
# ------------------------------------------------------------
# 【谁调它】big ④(执行者 = 被打中的那只生物)
# 【伤害】#ld_dmg zx.meta(已算好的整数) -> 打在被标记的那只生物身上。
# 【归属】用快照 u0..u3 反查射手; 查不到就无来源(仍打伤害)。
# ============================================================

data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work ld.snap.u0
data modify storage zx:work a.u1 set from storage zx:work ld.snap.u1
data modify storage zx:work a.u2 set from storage zx:work ld.snap.u2
data modify storage zx:work a.u3 set from storage zx:work ld.snap.u3
execute store result storage zx:work a.damage double 1 run scoreboard players get #ld_dmg zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
