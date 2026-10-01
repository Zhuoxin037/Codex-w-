# ============================================================
# sweetdream:equipment/bow/cold_crow/fire —— 按层数结算这一发(宏 {uuid,target,shooter})
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s 就是受害者, 但下面都显式用 $(target), 更清楚)
# 【按层数分四档】
#   1 层: 1 格内 冰冻 2 秒     2 层: 2 格内 冰冻 2 秒
#   3 层: 3 格内 冰冻 2 秒 + 最大魔力 ×0.1 伤害
#   4 层: 4 格内 冰冻 3 秒 + 最大魔力 ×0.25 伤害(射击时已经清空冰凌)
# 【范围怎么圈】以**被打中的那只**为中心开一个"判定箱相交"的盒子(边长 = 2×半径+1):
#   为什么不用 distance: 它量的是到生物**脚底**的距离, 人偶/坚守者这种高个子
#   会因为"脚太远"被漏掉 —— 而恰恰是它被打中, 不能漏(法球踩过这个坑)。
# 【冰冻怎么做的】走公共件 lib/freeze = 原版 TicksFrozen(>=140 完全冻结) + 移动速度归零,
#   详见那个文件(NoAI 那套"完全定格"是时停, 走 lib/timestop, 两者不混用)。
# 【伤害数值从哪来】射击那一刻就算好、存在射手名下的 dmg(已过"下一次技能加成"),
#   带着射手的 UUID 走 internal/damage/with_from → 击杀算射手的。
# ============================================================

# ① 这一发是第几层(从射手名下读)
$execute store result score #tier zx.meta run data get storage zx:data cc."$(uuid)".tier

# ② 圈出这一档的范围(以被打中的那只为中心)
tag @e[tag=zx.cc_aoe] remove zx.cc_aoe
$execute at $(target) if score #tier zx.meta matches 1 positioned ~-1.5 ~-1.5 ~-1.5 run tag @e[type=!#sweetdream:no_damage,dx=3.0,dy=3.0,dz=3.0] add zx.cc_aoe
$execute at $(target) if score #tier zx.meta matches 2 positioned ~-2.5 ~-2.5 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=5.0,dz=5.0] add zx.cc_aoe
$execute at $(target) if score #tier zx.meta matches 3 positioned ~-3.5 ~-3.5 ~-3.5 run tag @e[type=!#sweetdream:no_damage,dx=7.0,dy=7.0,dz=7.0] add zx.cc_aoe
$execute at $(target) if score #tier zx.meta matches 4 positioned ~-4.5 ~-4.5 ~-4.5 run tag @e[type=!#sweetdream:no_damage,dx=9.0,dy=9.0,dz=9.0] add zx.cc_aoe

# ③ 冰冻(1~3 层 2 秒 = 40 tick; 4 层 3 秒 = 60 tick)
data modify storage zx:work fz set value {target:"@e[tag=zx.cc_aoe]",ticks:40}
execute if score #tier zx.meta matches 4 run data modify storage zx:work fz.ticks set value 60
function sweetdream:lib/freeze with storage zx:work fz

# ④ 伤害(只有 3 / 4 层): 数值 + 归属都在射击那一刻定好了
data modify storage zx:work a set value {target:"@e[tag=zx.cc_aoe]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
$data modify storage zx:work a.damage set from storage zx:data cc."$(uuid)".dmg
$data modify storage zx:work a.u0 set from storage zx:data cc."$(uuid)".u0
$data modify storage zx:work a.u1 set from storage zx:data cc."$(uuid)".u1
$data modify storage zx:work a.u2 set from storage zx:data cc."$(uuid)".u2
$data modify storage zx:work a.u3 set from storage zx:data cc."$(uuid)".u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
execute if score #tier zx.meta matches 3.. run function sweetdream:internal/damage/with_from with storage zx:work a

# ⑤ 表现(画在被打中的那只身上) + 收尾清理
$execute at $(target) run particle minecraft:snowflake ~ ~1 ~ 1.4 0.8 1.4 0.05 40 normal
$execute at $(target) run particle minecraft:item_snowball ~ ~1 ~ 0.8 0.5 0.8 0.05 20 normal
$execute at $(target) run playsound minecraft:entity.player.hurt_freeze player @a ~ ~ ~ 0.9 1.0
execute if score #tier zx.meta matches 4 run playsound minecraft:block.glass.break player @a ~ ~ ~ 1.0 0.8

tag @e[tag=zx.cc_aoe] remove zx.cc_aoe
tag @e[tag=zx.cc_v] remove zx.cc_v
tag @e[tag=zx.cc_pl] remove zx.cc_pl
