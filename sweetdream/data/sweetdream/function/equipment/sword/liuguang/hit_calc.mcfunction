# ============================================================
# sweetdream:equipment/sword/liuguang/hit_calc —— 真的打出这一下(宏 {uuid,target_tag,damage,u0..u3})
# 【执行者】被打中的那只生物
# 【★ 优化建议第 2 条 ★】这里**不再** `data remove entity @s data.zx` ——
#   以前那一句会把生物的通用标签(渊海/流火/噬心…)和图标数据一起删掉。
#   现在数据都在施法者的记录里(zx:data lg.<uuid>), 生物身上只有原版标签, 不用清理。
# ============================================================

$tag @s remove $(target_tag)
data modify storage zx:work a.num set value 0.0
$data modify storage zx:work a.num set value $(damage)
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@s"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
function sweetdream:internal/damage/with_from with storage zx:work a
execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.4 0.4 0.4 0.15 30 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.8 1.2