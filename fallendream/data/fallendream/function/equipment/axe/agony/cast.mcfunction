# ============================================================
# fallendream:equipment/axe/agony/cast —— 苦痛: 锁定传染之痛(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/agony 的奖励函数(右键消耗时, 玩家身份)
# 【文案（用户 2026-11-01 原稿 · 原版）】消耗 600 魔力 / 冷却 100 秒。
#   使用后召唤一个术阵。之后使离自身最近的一个生物每秒受到相当于释放者基础攻击力
#   ×2 的伤害。若持续期间该生物死亡则对其 2 格内的全部生物造成一次相当于其最大
#   生命值的伤害, 之后使该效果延续到离它最近的一个生物上。该效果持续 15 秒。
# 【文案（用户 2026-11-20 原稿 · 超限）】同上，但：
#   · 死亡 AoE 要"并附加一个随机标签"
#   · 效果持续 16 秒
#   · 使用技能期间再次使用技能后在 4 秒内攻击一个其他生物则可以把本武器技能效果
#     转移到该生物上，且持续时间 +1 秒，每个技能期间只能使用一次
# 【状态全在目标身上】
#   tag zx.ag_t      = "我是苦痛的锁"(每秒驱动的筛选器)
#   data.zx.ag       = {uuid, u0..u3, ?ol} 释放者身份(算伤害基数 + 击杀归属)
#                      ol:1b = 这一轮是超限施放的（死亡分支据此补"随机标签"）
#   zx.ag_end(计分)  = 结束时刻(框架时钟), 到点由 second 摘标签
#   描述没写锁定范围 —— 取 8 格(和本批枯枝园召唤距离一致)。
# 【传染不重置时长】"使该效果延续到离它最近的一个生物上" —— 延续的是
#   **原锁剩下的时间**, 不重新计满(描述的"该效果持续 N 秒"修饰整个效果)。
# 【归属】DoT / 死亡 AoE 的伤害都带释放者 u0..u3(照寒鸦箭的模式:
#   预置进 zx:in arg, api/damage 的 merge 会带进去; 执行者是生物时
#   它不会用 @s 覆盖) —— 击杀照样记在玩家头上。
# 【★ 超限的"再按一次"是骑乘式的 ★】冷却 100 秒，正常根本按不了第二次；
#   文案要的"使用技能期间再次使用技能"只能是不扣蓝、不进冷却、不重放术阵的
#   一次性开窗动作 —— 见 xfer_arm。窗口 4 秒，整轮只能开一次(zx.ag_xn)。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only fallendream:equipment/axe/agony

# ① 拿 uuid
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 超限判定(主手 / 副手都认)
scoreboard players set #ag_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["agony"],ol:"agony"}] run scoreboard players set #ag_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["agony"],ol:"agony"}] run scoreboard players set #ag_ol zx.meta 1

# ③ 超限: 效果还在生效时的"再按一次" = 只开 4 秒转移窗口
#   ★ 无论开窗成功与否都 return 0：这一次右键绝不能再走下面的扣蓝/冷却/术阵流程。
execute if score #ag_ol zx.meta matches 1 if score @s zx.ag_live > #now manacore.meta run function fallendream:equipment/axe/agony/xfer_arm
execute if score #ag_ol zx.meta matches 1 if score @s zx.ag_live > #now manacore.meta run return 0

# ④ 有目标吗? 8 格内最近的一个(没有就整个不放 —— 不扣蓝、不进冷却)
#    ★ #fallendream:no_damage 含玩家 → 选择器天然不会锁到施法者自己
execute at @s unless entity @e[type=!#fallendream:no_damage,distance=..8] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute at @s unless entity @e[type=!#fallendream:no_damage,distance=..8] run return fail

# ⑤ 只读检查: 冷却 + 魔力 600
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:agony",mana:600.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"苦痛冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 600）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ⑥ 扣魔力 600
data modify storage manacore:in arg set value {uuid:"",value:600.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 600）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑦ 起冷却 100 秒
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:agony",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑧ 时长: 原版 15 秒 / 超限 16 秒(刻数与术阵秒数同源, 免得两处对不上)
scoreboard players set #ag_dur zx.meta 300
scoreboard players set #ag_durs zx.meta 15
execute if score #ag_ol zx.meta matches 1 run scoreboard players set #ag_dur zx.meta 320
execute if score #ag_ol zx.meta matches 1 run scoreboard players set #ag_durs zx.meta 16

# ⑨ 召唤术阵(与效果时长对齐; 满上限会失败, 不影响技能)
data modify storage manacore:in arg set value {uuid:"",id:"fallendream:agony",type:"agony",duration_seconds:15.0}
execute store result storage manacore:in arg.duration_seconds double 1 run scoreboard players get #ag_durs zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑩ 锁定: 8 格内最近的一个生物, 先冻结成标签再写状态
tag @e[tag=zx.ag_new] remove zx.ag_new
execute at @s run tag @e[type=!#fallendream:no_damage,distance=..8,sort=nearest,limit=1] add zx.ag_new
#   (上一行没选中 = 刚才④之前明明有目标, 中间一瞬没了 —— 罕见, 直接放空枪不补判定)

# ⑪ 把释放者身份写进目标(算伤害基数用 uuid; 打伤害带 u0..u3 归属)
data modify entity @e[tag=zx.ag_new,limit=1] data.zx.ag set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
data modify entity @e[tag=zx.ag_new,limit=1] data.zx.ag.uuid set from storage zx:data self.uuid
execute store result entity @e[tag=zx.ag_new,limit=1] data.zx.ag.u0 int 1 run data get entity @s UUID[0]
execute store result entity @e[tag=zx.ag_new,limit=1] data.zx.ag.u1 int 1 run data get entity @s UUID[1]
execute store result entity @e[tag=zx.ag_new,limit=1] data.zx.ag.u2 int 1 run data get entity @s UUID[2]
execute store result entity @e[tag=zx.ag_new,limit=1] data.zx.ag.u3 int 1 run data get entity @s UUID[3]
#   ★ 超限标记随身份一起走在目标身上（死亡分支据它补"随机标签"），
#     传染时整份 data.zx.ag 原样继承 ⇒ 超限那一轮全程都是超限。
execute if score #ag_ol zx.meta matches 1 run data modify entity @e[tag=zx.ag_new,limit=1] data.zx.ag.ol set value 1b

# ⑫ 结束时刻 + 挂上锁标签
scoreboard players operation @e[tag=zx.ag_new,limit=1] zx.ag_end = #now manacore.meta
scoreboard players operation @e[tag=zx.ag_new,limit=1] zx.ag_end += #ag_dur zx.meta
execute as @e[tag=zx.ag_new,limit=1] run tag @s add zx.ag_t
tag @e[tag=zx.ag_new] remove zx.ag_new

# ⑬ 玩家侧账本: 效果到期刻(超限"再按一次"的门控) / 本轮转移是否已用掉
scoreboard players operation @s zx.ag_live = #now manacore.meta
scoreboard players operation @s zx.ag_live += #ag_dur zx.meta
scoreboard players set @s zx.ag_xn 0
scoreboard players set @s zx.ag_xfer 0

# ⑭ 表现
execute at @s run particle minecraft:dust{color:[0.45,0.1,0.55],scale:1.4} ~ ~1 ~ 1.2 0.8 1.2 0.04 30 normal
execute at @s run particle minecraft:wax_on ~ ~1 ~ 0.8 0.8 0.8 0.02 15 normal
execute at @s run playsound minecraft:entity.warden.heartbeat player @a ~ ~ ~ 1.0 0.7
execute at @s run playsound minecraft:block.sculk_sensor.clicking player @a ~ ~ ~ 0.8 0.6
