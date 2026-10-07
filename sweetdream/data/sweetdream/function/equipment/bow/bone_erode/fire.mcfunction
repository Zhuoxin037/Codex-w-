# ============================================================
# sweetdream:equipment/bow/bone_erode/fire —— 蚀骨结算(宏 {target,shooter,uuid,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = victim)
# 【文案】对被射击生物 2 格内的全部生物造成 本次射击所消耗魔力值 ×0.4 的伤害。
# 【范围怎么圈】以被打中的那只为中心, 用"判定箱相交"(边长 = 2×半径+1 = 5) —— 
#   不用 distance(它量到脚底, 高个子会漏; 而恰恰是它被打中)。
# 【伤害数值】来自 snap_prep 合好的那份快照(逐箭优先, 射手最近一发兜底);
#   0 = 这一发没扣到魔力(没效果), 直接收工。
# 【★ 结算完必须清三个交汇标签 ★】zx.be_aoe / zx.be_v / zx.be_pl / zx.be_arr
#   都是"把几个回调接起来"的中转标签, 不清会污染下一发。
# ============================================================

# ① 伤害值(读 snap_prep 合好的快照)
scoreboard players set #be_dmg zx.meta 0
execute store result score #be_dmg zx.meta run data get storage zx:work be.snap.dmg 100
# 0 = 没扣魔力那一发, 收工(不打任何标签, 不用清理)
execute if score #be_dmg zx.meta matches ..0 run return 0

# ② 圈范围: 以被打中的那只为中心, 2 格内全部生物
tag @e[tag=zx.be_aoe] remove zx.be_aoe
$execute at $(target) positioned ~-2.5 ~-2.5 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=5.0,dz=5.0] add zx.be_aoe

# ③ 打伤害(带射手归属)
data modify storage zx:work a set value {target:"@e[tag=zx.be_aoe]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
execute store result storage zx:work a.damage double 0.01 run scoreboard players get #be_dmg zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 表现(骨屑爆开, 画在被打中的那只身上)
$execute at $(target) run particle minecraft:item{item:"minecraft:bone"} ~ ~1 ~ 1.2 0.6 1.2 0.05 30 normal
$execute at $(target) run particle minecraft:block{block_state:"minecraft:bone_block"} ~ ~1 ~ 0.8 0.5 0.8 0.02 10 normal
$execute at $(target) run playsound minecraft:entity.skeleton.hurt player @a ~ ~ ~ 0.8 1.0

# ⑤ 收尾: 清干净四个交汇标签
tag @e[tag=zx.be_aoe] remove zx.be_aoe
tag @e[tag=zx.be_v] remove zx.be_v
tag @e[tag=zx.be_pl] remove zx.be_pl
tag @e[tag=zx.be_arr] remove zx.be_arr
