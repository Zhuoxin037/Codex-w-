# ============================================================
# sweetdream:equipment/sword/deepsea_echo/wave_go —— 推进一波(宏参数 {uuid})
# ------------------------------------------------------------
# 【执行者】施法者本人
# 【这一波干什么】
#   ① 上一波的"源"没了(死光/被清) -> 直接收尾
#   ② 清掉上一波留下的临时标记
#   ③ 算这一波的伤害 = 当前魔力 ×0.15 (算进 manacore:out r.damage)
#   ④ 每个源各自对周围 3 格结算一次(hit_area)
#   ⑤ 把"本波被打到的"升级成"下一波的源"
#   ⑥ left 减 1: 还 >0 就再花 110 魔力、1 秒后下一波; 否则收尾
# 【为什么伤害只算一次】每个源打出的数值是一样的, 算一次放进
#   manacore:out r.damage, hit_area 直接 read:"manacore" 读 —— 不用层层传参。
# ============================================================

# ① 没源了 -> 收尾
$execute unless entity @e[tag=zx.de_$(uuid)] run function sweetdream:equipment/sword/deepsea_echo/finish with storage zx:work de
$execute unless entity @e[tag=zx.de_$(uuid)] run return 0

# ② 清掉上一轮的临时标记
tag @e[tag=zx.de_hit] remove zx.de_hit
tag @e[tag=zx.de_all] remove zx.de_all

# ③ 这一波的伤害 = 当前魔力 ×0.15
data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",base_attack:-1.0,skill_multiplier:0.15,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.base_attack set from storage manacore:out r.value
function manacore:api/damage/calc

# ④ 每个源各结算一次(execute as 换成源的执行者, at @s 把位置也带过去)
#   表现分两头:
#     · 每个源身上冒气泡柱(bubble + bubble_column_up) —— 海味的"水在涌"
#     · 3 格的伤害范围由 hit_area 里的 sfx_ring3 画成蓝色
#   音效只在第一个源的位置放一次 —— 每个源都放会叠成噪音。
$execute at @e[tag=zx.de_$(uuid),limit=1] run playsound minecraft:entity.guardian.ambient player @a ~ ~ ~ 0.8 0.7
$execute at @e[tag=zx.de_$(uuid)] run particle minecraft:bubble ~ ~1.2 ~ 0.45 0.5 0.45 0.02 20 normal
$execute at @e[tag=zx.de_$(uuid)] run particle minecraft:bubble_column_up ~ ~0.2 ~ 0.3 0.2 0.3 0.02 8 normal
$execute as @e[tag=zx.de_$(uuid),limit=8] at @s run function sweetdream:equipment/sword/deepsea_echo/hit_area

# 到下一波之间的那一秒里, 每 5 tick 补画一次水球(粒子寿命短, 只能补画)
# 范围环补画改由每秒循环负责(见 lib/second) —— 优化建议第 3 条



# ⑤ 传递: 本波被打到的 -> 下一波的源
$tag @e[tag=zx.de_all] add zx.de_$(uuid)
tag @e[tag=zx.de_all] remove zx.de_all

# ⑥ 还剩几次重复?
$execute store result score #left zx.meta run data get storage zx:data de."$(uuid)".left
scoreboard players remove #left zx.meta 1
$execute store result storage zx:data de."$(uuid)".left int 1 run scoreboard players get #left zx.meta

# 还要重复 -> 再花 110 魔力; 够就 1 秒后下一波, 不够就中断(并把标记清干净)
execute if score #left zx.meta matches 1.. run function sweetdream:equipment/sword/deepsea_echo/pay_mana
execute if score #left zx.meta matches 1.. if data storage manacore:out r{success:1b} run schedule function sweetdream:equipment/sword/deepsea_echo/wave 1s
execute if score #left zx.meta matches 1.. if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足, 连锁中断","color":"red"}]
execute if score #left zx.meta matches 1.. if data storage manacore:out r{success:0b} run function sweetdream:equipment/sword/deepsea_echo/finish with storage zx:work de
execute if score #left zx.meta matches ..0 run function sweetdream:equipment/sword/deepsea_echo/finish with storage zx:work de
