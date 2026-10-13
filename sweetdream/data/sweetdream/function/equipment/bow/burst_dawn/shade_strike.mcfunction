# ============================================================
# sweetdream:equipment/bow/burst_dawn/shade_strike —— 影每 3 秒的那一下
# ------------------------------------------------------------
# 【谁调用它】shade_tick ②(倒计时归零时), 由 lib/second 每秒驱动。
# 【执行者】魂灵之影(铁傀儡), 位置 = 它自己
# 【文案逐字】「其每 3 秒都会对其 3 格内的一个生物造成相当于其当前生命值 ×0.5
#   的伤害并使其获得 1 秒缓慢Ⅱ。」
# 【★ "一个" = 随机一只 ★】3 格内可能同时站着好几只; 文案说"一个", 所以
#   sort=random,limit=1 挑一只。
# 【★ 为什么伤害走 custom_damage(不吃三通道)★】
#   这一下的基数是**目标的当前生命值**, 既不是玩家最大魔力也不是面板攻击力 ——
#   按口径表(lib/skill_mul/def)它就是"生命/固定伤害口径", 不该吃玩家的
#   通道加成(超限/装备对 oth 通道的加成套到"敌人血量 ×0.5"上是错的)。
#   calc 的 custom_damage 正好是"固定伤害", 与 RULES 的 seg_x 口径一致。
# 【精度】data get ... Health 1000 拿到的是"当前生命 ×1000 取整", 再 ×0.0005
#   = 当前生命 ×0.5(千分位精度, 与圣骸 relic_spawn 存最大生命同一套写法)。
# 【伤害归属】归属给**主人**(u0..u3 存在影身上), 这样击杀记在玩家头上,
#   圣骸 / 黄昏黎明那类"技能击杀"进度照常触发。
# ============================================================

# ① 3 格内随机一只生物(排除玩家 / 非生物 / 别的影)
tag @e[tag=zx.bd_ht,distance=0..] remove zx.bd_ht
execute positioned ~-3.0 ~-3.0 ~-3.0 run tag @e[type=!#sweetdream:no_damage,tag=!zx.bd_shade,dx=6.0,dy=6.0,dz=6.0,sort=random,limit=1] add zx.bd_ht
execute unless entity @e[tag=zx.bd_ht,distance=0..,limit=1] run return 0

# ② 伤害 = 那只的**当前**生命 ×0.5
execute store result storage zx:work bs.hp double 0.0005 run data get entity @e[tag=zx.bd_ht,distance=0..,limit=1] Health 1000
data modify storage zx:work bs.uu set from entity @s data.zx.bd.uu
data modify storage manacore:in arg set value {uuid:"",custom_damage:0.0}
data modify storage manacore:in arg.uuid set from storage zx:work bs.uu
data modify storage manacore:in arg.custom_damage set from storage zx:work bs.hp
function manacore:api/damage/calc
data modify storage zx:work bs.dmg set value 0.0
data modify storage zx:work bs.dmg set from storage manacore:out r.damage

# ③ 打出去(归属 = 主人)
data modify storage zx:work a set value {target:"@e[tag=zx.bd_ht,distance=0..,limit=1]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work a.damage set from storage zx:work bs.dmg
data modify storage zx:work a.u0 set from entity @s data.zx.bd.u0
data modify storage zx:work a.u1 set from entity @s data.zx.bd.u1
data modify storage zx:work a.u2 set from entity @s data.zx.bd.u2
data modify storage zx:work a.u3 set from entity @s data.zx.bd.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 1 秒缓慢Ⅱ(amplifier 1 = Ⅱ)
effect give @e[tag=zx.bd_ht,distance=0..,limit=1] minecraft:slowness 1 1 true

# ⑤ 表现 + 收尾
execute at @e[tag=zx.bd_ht,distance=0..,limit=1] run particle minecraft:soul ~ ~1 ~ 0.3 0.4 0.3 0.03 16 normal
execute at @e[tag=zx.bd_ht,distance=0..,limit=1] run playsound minecraft:entity.skeleton.hurt player @a ~ ~ ~ 0.5 1.6
tag @e[tag=zx.bd_ht,distance=0..] remove zx.bd_ht
