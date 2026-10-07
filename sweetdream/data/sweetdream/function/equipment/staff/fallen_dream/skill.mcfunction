# ============================================================
# sweetdream:equipment/staff/fallen_dream/skill —— 堕梦: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 500 魔力 / 冷却 100 秒。使用后召唤一个术阵。之后使自身 8 格内
#   未处于时停状态的生物时停 3 秒并附加「白昼梦」效果。
#   若处于时停状态则时停时间 +2 秒。之后使其在接下来的时停时间内每秒受到
#   一次相当于使用者当前魔力值 ×0.04 的伤害。
# 【★ "+2 秒"是叠加不是取最大 ★】lib/timestop 的重入语义是"取较长那次"
#   (只会把结束时刻往后推到 max) —— 对已在时停里的生物, 直接给 zx.ts_end
#   加 40 tick 才是真正的"+2 秒"。
# 【DoT 挂在生物身上】tag zx.fd_t + data.zx.fd{uuid,u0..u3}(释放者身份):
#   每秒由 second 驱动 one 结算; 目标脱离时停(自然到期/被解)的下一秒摘标收工
#   —— "接下来的时停时间内"天然限定, 不用另设计时器。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/fallen_dream

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 500
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fallen_dream",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"堕梦冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 500）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 500
data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 500）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 100 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fallen_dream",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 召唤术阵(5 秒, 视觉存在)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:fallen_dream",type:"dream",duration_seconds:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 圈 8 格内的全部生物
tag @e[tag=zx.fd_area] remove zx.fd_area
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8] add zx.fd_area

# ⑦ 未时停的: 时停 3 秒 + 附加「白昼梦」
data modify storage zx:work fz set value {target:"@e[tag=zx.fd_area,tag=!zx.stop]",ticks:60}
function sweetdream:lib/timestop with storage zx:work fz
data modify storage zx:work mk set value {target:"@e[tag=zx.fd_area,tag=!zx.stop]",mark:"dream"}
function sweetdream:tag/mark with storage zx:work mk

# ⑧ 已时停的: 时停时间 +2 秒(直接给结束时刻加 40 tick, 见头注释)
execute as @e[tag=zx.fd_area,tag=zx.stop] run scoreboard players add @s zx.ts_end 40

# ⑨ 全部挂 DoT 标记 + 释放者身份
#   ★ execute store result entity 只收"单个实体"(多目标会让整个函数加载失败,
#   2026-10-05 真实报错) —— 所以趁 @s 还是释放者时先把 UUID 四个 int 抄进
#   storage, 再 as 循环逐个生物写回去。
execute store result storage zx:work fd.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work fd.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work fd.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work fd.u3 int 1 run data get entity @s UUID[3]
execute as @e[tag=zx.fd_area] run data modify entity @s data.zx.fd set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
execute as @e[tag=zx.fd_area] run data modify entity @s data.zx.fd.uuid set from storage zx:data self.uuid
execute as @e[tag=zx.fd_area] run data modify entity @s data.zx.fd.u0 set from storage zx:work fd.u0
execute as @e[tag=zx.fd_area] run data modify entity @s data.zx.fd.u1 set from storage zx:work fd.u1
execute as @e[tag=zx.fd_area] run data modify entity @s data.zx.fd.u2 set from storage zx:work fd.u2
execute as @e[tag=zx.fd_area] run data modify entity @s data.zx.fd.u3 set from storage zx:work fd.u3
tag @e[tag=zx.fd_area] add zx.fd_t

# ⑩ 表现 + 清理
execute at @s run particle minecraft:dust{color:[0.35,0.3,0.4],scale:1.5} ~ ~1 ~ 1.6 0.8 1.6 0.04 40 normal
execute at @s run particle minecraft:witch ~ ~1 ~ 1.0 0.8 1.0 0.02 30 normal
execute at @s run playsound minecraft:entity.illusioner.cast_spell player @a ~ ~ ~ 1.0 0.6
tag @e[tag=zx.fd_area] remove zx.fd_area
