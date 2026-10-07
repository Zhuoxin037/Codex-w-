# ============================================================
# sweetdream:equipment/staff/delusion/skill —— 惑梦: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 300 魔力 / 冷却 60 秒。使用后召唤一个术阵。之后锁定 8 格内
#   离自身最近的一个生物, 之后使其 3 格内的全部生物时停 2 秒。
#   若锁定的生物处于时停状态则改为使其 5 格内的全部生物受到一次相当于自身
#   最大魔力值 ×0.1 的伤害并时停 3 秒。
# 【★ 分支顺序 ★】先看锁定的那只"在不在时停里"(tag zx.stop), 再决定走哪段 ——
#   绝不能写成"先时停再看"(那样第二段的判定永远成立, note 里专门提醒过)。
#   两段共用"以锁定者为中心的圈子"(zx.dl_area), 各自圈各自的半径。
# 【时停用 lib/timestop】NoAI 定格 + zx.stop 标签; 自带重入保护与
#   "时长只延长不缩短"。"其 3 格内"以锁定者为中心, 它自己距离 0 也算在内。
# 【一次性结算】没有每秒驱动 —— 打完即收, 不挂 second。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/delusion

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 有目标吗? 8 格内最近的一个(没有就整个不放 —— 不扣蓝、不进冷却)
tag @e[tag=zx.dl_lock] remove zx.dl_lock
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,sort=nearest,limit=1] add zx.dl_lock
execute unless entity @e[tag=zx.dl_lock,limit=1] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[tag=zx.dl_lock,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力 300
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:delusion",mana:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"惑梦冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 300）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力 300
data modify storage manacore:in arg set value {uuid:"",value:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 300）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 60 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:delusion",cooldown_seconds:60.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 召唤术阵(5 秒, 视觉存在)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:delusion",type:"dream",duration_seconds:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑦ 分支 A: 锁定的生物已在时停里 → 5 格 AoE(最大魔力×0.1) + 时停 3 秒
execute if entity @e[tag=zx.dl_lock,tag=zx.stop,limit=1] run function sweetdream:equipment/staff/delusion/skill_a

# ⑧ 分支 B: 没在时停 → 其 3 格内全部生物时停 2 秒
#   (与 A 互斥: A 走完锁定者依旧带 zx.stop, B 的 unless 永远不成立, 不会双放)
execute unless entity @e[tag=zx.dl_lock,tag=zx.stop,limit=1] run function sweetdream:equipment/staff/delusion/skill_b

# ⑨ 表现(先放, 标签还在) + 清理
execute at @e[tag=zx.dl_lock,limit=1] run particle minecraft:dust{color:[0.75,0.4,0.9],scale:1.3} ~ ~1 ~ 1.2 0.8 1.2 0.04 30 normal
execute at @e[tag=zx.dl_lock,limit=1] run particle minecraft:witch ~ ~1 ~ 0.8 0.8 0.8 0.02 20 normal
execute at @s run playsound minecraft:entity.illusioner.mirror_move player @a ~ ~ ~ 0.9 0.7
tag @e[tag=zx.dl_lock] remove zx.dl_lock
tag @e[tag=zx.dl_area] remove zx.dl_area
