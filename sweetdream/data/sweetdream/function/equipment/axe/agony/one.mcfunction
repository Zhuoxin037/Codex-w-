# ============================================================
# sweetdream:equipment/axe/agony/one —— 苦痛: 对一只被锁生物结算一秒
# ------------------------------------------------------------
# 【谁调用它】second 里 `execute as @e[tag=zx.ag_t] at @s`(执行者 = 被锁生物)
# 【流程】到期摘锁 → 每秒 DoT(释放者基础攻击力×2) → 死了进死亡分支
#   (2 格 AoE = 死者最大生命值 + 传染给离它最近的生物, 剩余时间不变)
# 【死亡判定为什么可靠】生物被打死后会以 Health:0.0f 的"尸体状态"再存在
#   约 20 tick(死亡动画)才被移除 —— 本函数在打完伤害的这一秒就能看到
#   Health:0.0f(和 internal/damage/one 的击杀记账是同一套判定)。
#   所以**位置/最大生命/归属都不用提前快照**, 尸体身上全读得到。
#   死亡分支第一件事摘 zx.ag_t —— 下一秒驱动不会再选中它, 不会重复触发。
# 【DoT 的伤害基数实时算】每秒用目标身上的 data.zx.ag.uuid 去查释放者的
#   面板 base_attack —— 玩家换装后 DoT 跟着变(描述口径是"释放者基础攻击力")。
#   释放者离线时查不到 → 伤害为 0(优雅降级, 不报错)。
# 【归属】DoT / 死亡 AoE 都预置 u0..u3 进 zx:in arg —— 执行者是生物时
#   api/damage 不会用 @s 覆盖它们 → 击杀记在释放者头上。
# ============================================================

# ① 到期? (框架时钟拷一份出来比)
scoreboard players operation #now2 zx.meta = #now manacore.meta
execute if score @s zx.ag_end <= #now2 zx.meta run tag @s remove zx.ag_t
execute unless entity @s[tag=zx.ag_t] run return 0

# ② 算 DoT 伤害 = 释放者基础攻击力 ×2
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from entity @s data.zx.ag.uuid
function manacore:api/stats/get
scoreboard players set #dmg zx.meta 0
execute store result score #dmg zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #dmg zx.meta *= #2 zx.meta

# ③ 打出去(带释放者归属)
data modify storage zx:in arg set value {target:"@s",damage:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:in arg.damage double 0.01 run scoreboard players get #dmg zx.meta
data modify storage zx:in arg.u0 set from entity @s data.zx.ag.u0
data modify storage zx:in arg.u1 set from entity @s data.zx.ag.u1
data modify storage zx:in arg.u2 set from entity @s data.zx.ag.u2
data modify storage zx:in arg.u3 set from entity @s data.zx.ag.u3
function sweetdream:api/damage

# ④ 还活着 → 本秒收工
execute if entity @s[tag=zx.ag_t] unless data entity @s {Health:0.0f} run return 0

# ============================================================
# —— 死亡分支(实体处于 Health:0 的尸体状态, 下面都还读得到) ——
# ============================================================

# ⑤ 先摘锁(下一秒驱动不再选中它), 再放表现
tag @s remove zx.ag_t
execute at @s run particle minecraft:dust{color:[0.45,0.1,0.55],scale:1.6} ~ ~1 ~ 1.0 0.8 1.0 0.06 40 normal
execute at @s run particle minecraft:sonic_boom ~ ~1 ~ 0 0 0 0.0 1 normal
execute at @s run playsound minecraft:entity.warden.sonic_boom player @a ~ ~ ~ 0.6 1.4

# ⑥ AoE: 对 2 格内全部生物造成相当于死者最大生命值的伤害
#   (先把尸体自己从集合里摘掉, 免得对已死之人再打一下)
scoreboard players set #mhp zx.meta 0
execute store result score #mhp zx.meta run data get entity @s attributes[{id:"minecraft:max_health"}].base 100
tag @e[tag=zx.ag_dead] remove zx.ag_dead
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.ag_dead
tag @s remove zx.ag_dead
data modify storage zx:in arg set value {target:"@e[tag=zx.ag_dead]",damage:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:in arg.damage double 0.01 run scoreboard players get #mhp zx.meta
data modify storage zx:in arg.u0 set from entity @s data.zx.ag.u0
data modify storage zx:in arg.u1 set from entity @s data.zx.ag.u1
data modify storage zx:in arg.u2 set from entity @s data.zx.ag.u2
data modify storage zx:in arg.u3 set from entity @s data.zx.ag.u3
function sweetdream:api/damage
tag @e[tag=zx.ag_dead] remove zx.ag_dead

# ⑦ 传染: 离死者最近的一个活物(8 格内; nbt=!{Health:0.0f} 顺手排掉别的尸体)
#   剩余时间/释放者身份原样继承 —— 继承的对象可能是别的锁的目标,
#   此时相当于"锁转移", 语义仍然是"延续到离它最近的一个生物上"。
scoreboard players set #ag_end zx.meta 0
execute store result score #ag_end zx.meta run scoreboard players get @s zx.ag_end
tag @e[tag=zx.ag_new] remove zx.ag_new
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,nbt=!{Health:0.0f},sort=nearest,limit=1] add zx.ag_new
data modify entity @e[tag=zx.ag_new,limit=1] data.zx.ag set from entity @s data.zx.ag
execute as @e[tag=zx.ag_new,limit=1] run scoreboard players operation @s zx.ag_end = #ag_end zx.meta
execute as @e[tag=zx.ag_new,limit=1] run tag @s add zx.ag_t
execute as @e[tag=zx.ag_new,limit=1] at @s run particle minecraft:wax_on ~ ~1 ~ 0.6 0.6 0.6 0.02 12 normal
tag @e[tag=zx.ag_new] remove zx.ag_new
