# ============================================================
# sweetdream:equipment/bow/burst_dawn/fire_hit —— 把 zx:work bd.dmg 打给圈里的全体
# ------------------------------------------------------------
# 【执行者】射手(玩家); 由 fire 在"第一段 / 第二段"各调一次
# 【为什么要单独一个文件】两段只是伤害数值不同、 대상 完全相同 —— 抽出来省得
#   把"打伤害的六行"抄两遍(抄两遍的地方迟早会只改一处)。
# 【伤害归属】带 u0..u3 走 internal/damage/with_from -> 击杀记在射手头上,
#   原版 player_killed_entity 进度(黄昏黎明那 5 条标签进度)也照常触发。
# 【★ 每只目标都各自过一遍 internal/damage/one ★】升痕 / 夜火易伤 / 噬心
#   那些"按目标结算"的加成都在里面, 所以段伤害只负责给出一个基数。
# ============================================================

data modify storage zx:work a set value {target:"@e[tag=zx.bd_aoe,distance=0..]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work bd.dmg
execute store result storage zx:work a.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work a.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work a.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work a.u3 int 1 run data get entity @s UUID[3]
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
