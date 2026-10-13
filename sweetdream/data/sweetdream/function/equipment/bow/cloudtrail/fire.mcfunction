# ============================================================
# sweetdream:equipment/bow/cloudtrail/fire —— 「云迹」领域同步伤害(宏 {target,shooter,uuid})
# ------------------------------------------------------------
# 【执行者】射手(玩家), 位置 = 射手自己(apply 用 as/at 送进来)
# 【技能原文(lore 逐字)】
#   「当自身射击在领域内的生物时会同步对领域内的全部生物造成一次相当于
#    自身基础攻击力 ×2 的伤害。」
# 【触发条件(缺一不可)】① 这一箭命中了生物(由 hook_victim 保证)
#   ② 被命中的那只**落在射手自己的某个领域内**。不是自己的领域不算(文案"自身"的)。
# 【怎么判"落在领域内"】领域 = 半径 3 的 marker, 所以"受害者到某个自己的领域中心
#   的距离 ≤ 3"。写得离受害者最近的那个(limit=1,sort=nearest), 一次触发只吃一个领域
#   —— 两个领域重叠时不重复结算。
# 【伤害只算一次】"自身基础攻击力 ×2" 与打中谁无关, 所以算一次、给领域内全体复用。
#   每只目标照常过 internal/damage/one(升痕/易伤按目标逐只结算)。
# 【范围怎么圈】以**领域中心**为圆心开边长 6 的判定箱(-3.0..+3.0 = 半径 3),
#   和寒鸦/法球同款 —— 不用 distance(高个子会因为"脚太远"被漏掉)。
# ============================================================

# ① 找出"自己的、且把受害者罩在里面"的领域(最近的; 没有就收工)
tag @e[tag=zx.ct_f,distance=0..] remove zx.ct_f
$execute at $(target) run tag @e[tag=zx.ct_field,nbt={data:{zx:{uu:"$(uuid)"}}},distance=..3,limit=1,sort=nearest] add zx.ct_f
execute unless entity @e[tag=zx.ct_f,distance=0..,limit=1] run return 0

# ② 这一下造成的伤害 = 自身基础攻击力 ×2(attack 通道, 基数默认面板基础攻击力)
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:work ct.uuid
function manacore:api/damage/calc
data modify storage zx:work ct.dmg set value 0.0
data modify storage zx:work ct.dmg set from storage manacore:out r.damage

# ③ 圈出领域范围(半径 3, 圆心 = 领域中心)
tag @e[tag=zx.ct_aoe,distance=0..] remove zx.ct_aoe
execute at @e[tag=zx.ct_f,distance=0..,limit=1] positioned ~-3.0 ~-3.0 ~-3.0 run tag @e[type=!#sweetdream:no_damage,tag=!zx.bd_shade,dx=6.0,dy=6.0,dz=6.0] add zx.ct_aoe

# ④ 对领域内全体打这一下(归属 = 射手; u0..u3 供击杀记账)
data modify storage zx:work a set value {target:"@e[tag=zx.ct_aoe]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work ct.dmg
execute store result storage zx:work a.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work a.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work a.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work a.u3 int 1 run data get entity @s UUID[3]
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
execute if entity @e[tag=zx.ct_aoe,distance=0..,limit=1] run function sweetdream:equipment/bow/cloudtrail/fire_fx

# ⑤ 收尾: 清掉本次用过的"工作标签"(领域 marker 本身不动, 它按自己的 5 秒计时死)
tag @e[tag=zx.ct_f,distance=0..] remove zx.ct_f
tag @e[tag=zx.ct_aoe,distance=0..] remove zx.ct_aoe
