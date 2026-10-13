# ============================================================
# sweetdream:equipment/staff/fallen_dream/skill —— 堕梦: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 500 魔力 / 冷却 100 秒。使用后召唤一个术阵。之后使自身 8 格内
#   的全部生物附加「白昼梦」效果，若其未处于时停状态则使其时停 3 秒，
#   若其处于时停状态则使其时停时间 +2 秒。之后使其在接下来的时停时间内
#   每秒受到一次相当于使用者当前魔力值 ×0.04 的伤害。
# 【★ 白昼梦是"全体"不是"只有新时停的" ★】(2026-10-12 用户拍板)
#   白昼梦是堕梦普攻转真伤的联动条件 —— 只给"原本没时停"的那批, 已经在时停
#   里的目标打上去就没有真伤了。所以 mark 施给**圈内全体**(zx.fd_area)。
# 【★ "+2 秒"是叠加不是取最大 ★】lib/timestop 的重入语义是"取较长那次"
#   (只会把结束时刻往后推到 max) —— 对已在时停里的生物, 直接给 zx.ts_end
#   加 40 tick 才是真正的"+2 秒"。
# 【★ "谁原本在时停里"必须先快照(坑 123) ★】分流标签 zx.fd_new(原本没时停) /
#   zx.fd_old(原本就在时停) 必须在**改状态之前**打: lib/timestop 一挂上就把
#   zx.stop 改了, 之后再按 zx.stop 选人 ⇒ 白昼梦落空 + 新时停的被重复 +2 秒
#   (3 秒变 5 秒)。详见 ⑥.2 的注释。
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

# ⑥.2 ★★ 分流: **必须在改状态之前打** ★★(坑 123, 2026-10-12 用户实测两条 bug)
#   以前 ⑦⑧ 都是"现用现选"(直接写 tag=!zx.stop / tag=zx.stop), 而 ⑦ 的时停
#   一挂上, zx.stop 就已经变了:
#     · ⑦ 第二句再选 `tag=!zx.stop` ⇒ **空集** ⇒ 「白昼梦」一件都没附上;
#     · ⑧ 再选 `tag=zx.stop` ⇒ 把刚被 ⑦ 时停的这批也算成"原本就在时停里"
#       ⇒ 3 秒 + 2 秒 = **5 秒**(玩家看到的就是"说好的 3 秒变成 5 秒")。
#   正解 = 先把"谁是哪一类"抄成两个快照标签, 后面一律按快照取值。
tag @e[tag=zx.fd_new] remove zx.fd_new
tag @e[tag=zx.fd_old] remove zx.fd_old
tag @e[tag=zx.fd_area,tag=!zx.stop] add zx.fd_new
tag @e[tag=zx.fd_area,tag=zx.stop] add zx.fd_old

# ⑥.3 全体附加「白昼梦」(在改状态**之前**施: 认 zx.fd_area 不认 zx.stop)
#   ★ 必须早于 ⑦ —— ⑦ 一挂上 zx.stop, "未时停的那批"就再也选不出来了。
data modify storage zx:work mk set value {target:"@e[tag=zx.fd_area]",mark:"dream"}
function sweetdream:tag/mark with storage zx:work mk

# ⑦ 原本未时停的: 时停 3 秒(60 tick)
data modify storage zx:work fz set value {target:"@e[tag=zx.fd_new]",ticks:60}
function sweetdream:lib/timestop with storage zx:work fz

# ⑧ 原本已在时停里的: 时停时间 +2 秒(直接给结束时刻加 40 tick, 见头注释)
#   ★ 只认 zx.fd_old(快照) —— 认 zx.stop 会把 ⑦ 刚时停的这批一起加时。
execute as @e[tag=zx.fd_old] run scoreboard players add @s zx.ts_end 40

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
tag @e[tag=zx.fd_new] remove zx.fd_new
tag @e[tag=zx.fd_old] remove zx.fd_old
