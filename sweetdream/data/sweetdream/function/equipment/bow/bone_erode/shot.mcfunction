# ============================================================
# sweetdream:equipment/bow/bone_erode/shot —— 每次射击(蚀骨)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/bone_erode(触发器 shot_crossbow)。
# 【文案】消耗 = 本次射击所消耗魔力值的 20%; 对被射击生物 2 格内的全部生物
#   造成 本次射击所消耗魔力值 ×0.4 的伤害。
# 【"本次射击所消耗的魔力值"取多少】蚀骨没有单独的"每箭基础消耗"字段, 本实现
#   取基准 100 魔力(= 同族「幽匿残响」的每次射击消耗); 技能按 20% 名义扣,
#   伤害基数用 100 -> 2 格内每只 100×0.4 = 40 点。数值改下面两处即可。
# 【★ 魔力是射出去之后才扣的 ★】和寒鸦同理: 射击事件发生在箭离弦之后,
#   所以只能"没蓝就不生效"(提示一句), 不可能"没蓝就不射"。
# 【这一发怎么和"打中了谁"对上】交给弩上的附魔「蚀骨」回调(hook_victim),
#   原版判断"这支箭打中了生物"。命中前把这一发的伤害/归属写进射手名下 +
#   逐箭快照(和寒鸦同一套)。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/bone_erode
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 本次射击基准消耗
scoreboard players set #be_cost zx.meta 100

# ② 扣魔力: 文案写"消耗本次射击所消耗魔力值的 20%" -> 按名义扣基准的一份
#    (这里直接把"本次射击消耗"= 基准 100 扣掉; 若你想扣 20, 把 value 改成 20 即可)
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #be_cost zx.meta
function manacore:api/mana/consume

# ③ 魔力不足 -> 这一发什么都不做(清掉旧数据, 免得命中时读到上一发)
execute if data storage manacore:out r{success:0b} run data modify storage zx:work be.uuid set from storage zx:data self.uuid
execute if data storage manacore:out r{success:0b} run function sweetdream:equipment/bow/bone_erode/clear with storage zx:work be
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭没有蚀骨效果","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 把这一发的数据记在射手名下, 再写进这一箭自己身上(逐箭快照)
#    dmg = 基准 100 ×0.4 = 40(固定值, 不随面板变)
data modify storage zx:work be set value {uuid:"",dmg:0.0,u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work be.uuid set from storage zx:data self.uuid
data modify storage zx:work be.dmg set value 40.0
execute store result storage zx:work be.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work be.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work be.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work be.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/bone_erode/store with storage zx:work be
execute at @s as @e[type=#sweetdream:cc_arrow,tag=!zx.cc_seen,distance=..4] run function sweetdream:equipment/bow/bone_erode/snapshot with storage zx:work be

# ⑤ 表现: 骨屑
execute at @s run particle minecraft:item{item:"minecraft:bone"} ~ ~1.3 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.4

# ⑥ 「启示录」记页: 蚀骨的射击也是「✦ 主动技能」, 但弩没有冷却、不抛 cooldown_start,
#    只能在这里显式补一枪(见 apocalypse/spend)。放在最后: spend 会读 uuid / 写公共输入口, 别打断上面还在用的数据。
function sweetdream:equipment/staff/apocalypse/spend
