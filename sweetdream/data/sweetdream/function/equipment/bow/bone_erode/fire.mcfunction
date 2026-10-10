# ============================================================
# sweetdream:equipment/bow/bone_erode/fire —— 蚀骨结算(宏 {target,shooter,uuid,arrow})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = victim)
# 【文案(基础版)】对被射击生物 2 格内的全部生物造成 本次射击所消耗魔力值 ×0.4 的**伤害**。
# 【文案(超限·蚀骨, 2026-10-10 实装)】×0.4 -> **×0.5**, 且改打**真实伤害**;
#   另外"若生物上附有「噬心」则额外受到一次相当于本次伤害 80% 的真实伤害, 之后清除
#   「噬心」"。判据 = 这一发的快照 `be.snap.ol`(离弦时拍下的"手里是不是超限版蚀骨")。
#   ★ 两处解读点(已写进 使用教程, 等用户过目):
#     ① "生物"取 **2 格内全部生物** —— 与上一句同一集合, 不是只有被射中的那只;
#     ② "本次伤害"取 **名义值**(消耗魔力 ×0.5), 不含通用标签那层 +15%。
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

# ①' 这一发是不是超限版(同快照里的 ol; 离弦时拍的)
#    ★ 读不到(字段不存在)时 store 不执行, #be_ol 保持刚 set 的 0 -> 走基础版, 安全。
scoreboard players set #be_ol zx.meta 0
execute store result score #be_ol zx.meta run data get storage zx:work be.snap.ol 1

# ② 圈范围: 以被打中的那只为中心, 2 格内全部生物
tag @e[tag=zx.be_aoe] remove zx.be_aoe
$execute at $(target) positioned ~-2.5 ~-2.5 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=5.0,dz=5.0] add zx.be_aoe

# ③ 打伤害(带射手归属)
data modify storage zx:work a set value {target:"@e[tag=zx.be_aoe]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
#   ★ 超限: 覆盖成**真实伤害**(sweetdream:true_damage; 必须排在读 config 之后)
execute if score #be_ol zx.meta matches 1 run data modify storage zx:work a.type set value "sweetdream:true_damage"
execute store result storage zx:work a.damage double 0.01 run scoreboard players get #be_dmg zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 表现(骨屑爆开, 画在被打中的那只身上)
$execute at $(target) run particle minecraft:item{item:"minecraft:bone"} ~ ~1 ~ 1.2 0.6 1.2 0.05 30 normal
$execute at $(target) run particle minecraft:block{block_state:"minecraft:bone_block"} ~ ~1 ~ 0.8 0.5 0.8 0.02 10 normal
$execute at $(target) run playsound minecraft:entity.skeleton.hurt player @a ~ ~ ~ 0.8 1.0

# ④ ★ 超限: 2 格内带「噬心」的生物 -> 额外吃一次 本次伤害 ×80% 的真实伤害 ★
#   【为什么先打后清】文案顺序就是"额外受到一次…之后清除"; 而且「噬心」本身对**真实
#     伤害**有 +15%(见 internal/damage/one), 先打才吃得到这一层。
#   【逐只 as】每只带噬心的自己吃一次; 数值统一 = #be_dmg ×80%, 与"被射中的是哪只"无关。
execute if score #be_ol zx.meta matches 1 as @e[tag=zx.be_aoe,tag=zx.status.shixin] at @s run function sweetdream:equipment/bow/bone_erode/ol_shixin

# ⑤ ★ 超限: 之后清除这些「噬心」(统一入口 lib/mark_consume) ★
execute if score #be_ol zx.meta matches 1 run function sweetdream:equipment/bow/bone_erode/ol_consume

# ⑥ 收尾: 清干净四个交汇标签
tag @e[tag=zx.be_aoe] remove zx.be_aoe
tag @e[tag=zx.be_v] remove zx.be_v
tag @e[tag=zx.be_pl] remove zx.be_pl
tag @e[tag=zx.be_arr] remove zx.be_arr
