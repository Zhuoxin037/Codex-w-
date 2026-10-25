# ============================================================
# sweetdream:equipment/sword/liuguang/cast —— 流光: 锁定 + 延迟结算
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/liuguang 的奖励函数(右键消耗时, 以玩家身份)。
#   注意不是 effect_1 调的 —— 回手归 effect_1(通用线), 技能归本进度(武器自己的线)。
# 【流程】
#   ⓪ 撤销自己的进度 —— 不撤的话这个进度一辈子只触发一次
#   ① 拿 UUID
#   ② 只读检查(冷却 + 魔力 20) —— 不通过就什么都不做
#   ③ 先确认 8 格内有能锁的目标 —— 没有就整个不放(不扣蓝、不进冷却)
#   ④ 扣魔力  ⑤ 记冷却
#   ⑥ 算伤害(基础攻击力 x2, 保底 6)
#   ⑦ 锁定 + 把伤害和归属写上去 + 锁定表现(交给宏层, 见下)
#   ⑧ 3 秒后结算(到点时刻存在目标身上, 见 hit_due)
# 【⑦ 为什么要交给宏层】标记的名字里带施法者自己的 UUID(zx.lg_<uuid>),
#   而拼这种动态名字只能用宏变量。顺带把伤害/归属/粒子一起做了,
#   省得再穿一次宏。
# 【为什么随机挑完要立刻打标签】@e[sort=random] 每次求值都会重挑一个 ——
#   不冻结成标签的话, 后面每一步都可能作用在别人身上。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/liuguang

# ⓪.5 【超限分流】敲过超限石(ol:"liuguang")的流光, 右键放的是「超限·流光」,
#      原版技能被它顶掉 —— 见 equipment/sword/liuguang/overlimit。
#   ★ 主副手都要判, 判据用 items 复合谓词 (2026-10-08 修) —— 照 myriad/is_ol 的标准写法。
#     旧写法读 SelectedItem(只有主手那条虚拟只读路径), 而且只判 .ol 键在不在、
#     不判 ol 是不是 "liuguang": 主手空着/拿着普通剑、**副手是超限·流光**时,
#     会走成基础流光(20 蓝 / 1 目标 / 20 秒), 而不是超限的 120 蓝 / 4 目标 / 8 秒。
scoreboard players set #lg_ol zx.meta 0
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["liuguang"],ol:"liuguang"}] run scoreboard players set #lg_ol zx.meta 1
execute if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["liuguang"],ol:"liuguang"}] run scoreboard players set #lg_ol zx.meta 1
execute if score #lg_ol zx.meta matches 1 run function sweetdream:equipment/sword/liuguang/overlimit
execute if score #lg_ol zx.meta matches 1 run return 0

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力够不够
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liuguang",mana:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"流光冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 20)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 没有就整个不放
#    distance=0.1..8 的下界把自己排除掉(自己到自己是 0 格)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run return fail

# ④ 扣魔力
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却
#   只记冷却就够了 —— 观测镜是"看主手武器自带的 custom_data.skill"来决定显示
#   哪条冷却的, 不需要知道"你最近放过什么"。(早期那套 last_skill 已经删掉了。)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:liuguang",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 算伤害: 基础攻击力 x 2
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# 保底 6: 小于等于 5 就抬到 6(写在 out 上, 后面宏层直接读它)
execute store result score #dmg zx.meta run data get storage manacore:out r.damage 1
execute if score #dmg zx.meta matches ..5 run data modify storage manacore:out r.damage set value 6.0

# ⑦ 锁定 + 写数据 + 表现(全在宏层, 因为标记名字里要带自己的 UUID)
data modify storage zx:work a.uuid set from storage zx:data self.uuid
data modify storage zx:work a.damage set from storage manacore:out r.damage
function sweetdream:equipment/sword/liuguang/lock_macro with storage zx:work a

# 宏层没锁定成功(理论上不会, ③ 已经拦过一次)就到此为止
execute unless data storage zx:work a{locked:1b} run return fail

# ⑧ 打上"我有一笔结算待处理", 3 秒后由 hit 结算
tag @s add zx.lg_casting
# 由每秒循环扫到点结算(见 lib/second) —— 不再用一次性 schedule
