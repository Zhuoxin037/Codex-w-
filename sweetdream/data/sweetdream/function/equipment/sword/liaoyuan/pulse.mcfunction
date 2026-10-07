# ============================================================
# sweetdream:equipment/sword/liaoyuan/pulse —— 一次灼烧(每 2 秒一次; 以玩家身份)
# ------------------------------------------------------------
# 【一次脉冲做四件事】
#   ① 圈出自身 5 格内的生物(判定箱相交, 高个子/人偶都吃得到)
#   ② 伤害 = 自身最大魔力 ×0.04(走框架: 最大魔力口径 -> 吃「下一次技能加成」)
#   ③ "每 2 次之后的下一 次"(= 第 3 次)给这一轮受伤的生物附加「流火」(走通用标签接口, 带图标)
#   ④ 表现: 火焰粒子 + 营火噼啪声(附加流火那一次额外一声烈焰人)
# 【为什么用"次数"而不是"秒数"】文案是"每 2 次之后的下一 次附加流火",
#   所以数的是**灼烧次数**(zx.ly_times): 第 3、6、9 次附加(18 秒一共 9 次灼烧 -> 附加 3 次)。
# ============================================================

# ① 自己的 uuid(伤害口径要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 圈出自身 5 格内的生物
tag @e[tag=zx.ly_hit] remove zx.ly_hit
execute positioned ~-5 ~-5 ~-5 run tag @e[type=!#sweetdream:no_damage,dx=10,dy=10,dz=10] add zx.ly_hit

# ③ 伤害 = 最大魔力 ×0.04
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.04,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
# ★ 超限的伤害乘区(敲过超限才有效): 0.04 -> 0.05, 和 lore 里的数字一一对应
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.ly_hit]",read:"manacore"}
function sweetdream:api/damage

# ④ "每 2 次之后的下一 次": 附加「流火」
#   数的是"这次光环里第几次灼烧"(zx.ly_times): 第 3、6、9 次附加。
scoreboard players add @s zx.ly_times 1
scoreboard players operation #ly_e zx.meta = @s zx.ly_times
scoreboard players operation #ly_e zx.meta %= #3 zx.meta
execute if score #ly_e zx.meta matches 0 run data modify storage zx:work ic set value {target:"@e[tag=zx.ly_hit]",mark:"liuhuo"}
execute if score #ly_e zx.meta matches 0 run function sweetdream:tag/mark with storage zx:work ic

# ⑤ 表现
execute at @s run particle minecraft:flame ~ ~1 ~ 2.2 0.6 2.2 0.02 25 normal
execute at @s run playsound minecraft:block.campfire.crackle player @a ~ ~ ~ 0.7 1.1
execute if score #ly_e zx.meta matches 0 run playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.5 1.4
execute if score #ly_e zx.meta matches 0 run particle minecraft:small_flame ~ ~1 ~ 1.6 0.5 1.6 0.02 20 normal

# ⑥ 收尾
tag @e[tag=zx.ly_hit] remove zx.ly_hit
