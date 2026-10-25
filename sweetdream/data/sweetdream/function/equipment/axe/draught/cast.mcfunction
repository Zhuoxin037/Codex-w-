# ============================================================
# sweetdream:equipment/axe/draught/cast —— 饮鸩 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/draught(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 160 / 冷却 80 秒。
#   "使用后对自身造成相当于自身最大生命值 ×0.8 的伤害，之后获得相当于自身受到的伤害的
#    基础攻击力加成，持续 10 秒。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: 自身。
#   ③ 次数: 自伤 1 次; 加成 1 份。
#   ④ 时长: 10 秒(zx.dg_on = 10, 由 lib/second 每秒 -1, 归零由 expire 撤掉加成)。
# 【数值来源】"**受到的**伤害" = 自伤前后实测的血量差(不是写死的 0.8×最大生命) ——
#   万一被减伤, 加成也跟着少。血量按 ×10 读(0.1 精度), 差再 ÷10 取整。
# 【加到哪里】面板 base_attack(manacore:api/stats/add)。账本 zx.dg_buf 记"加了多少",
#   到期由 expire 用**同样的数**减回去(幂等)。
# 【重入】施法前先把上一轮残留的加成撤掉(见 strip), 不会越叠越多。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/draught

# ⓪.5 【超限分流】敲过超限石(ol:"draught")的饮鸩: 360 蓝 / 加成 = **本次伤害数值** /
#     持续 **12** 秒 / 放完之后血量 >60% 可再来一次(第二形态 = 每攻击一次自伤 10% 换 +10% 攻击)。
#   判据判 ol 的**值**(不是 .ol 键在不在), 主副手都判。
scoreboard players set #dg_ol zx.meta 0
execute if items entity @s weapon.mainhand iron_axe[minecraft:custom_data~{zx:["draught"],ol:"draught"}] run scoreboard players set #dg_ol zx.meta 1
execute if items entity @s weapon.offhand iron_axe[minecraft:custom_data~{zx:["draught"],ol:"draught"}] run scoreboard players set #dg_ol zx.meta 1

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.5 【第二形态】上一轮已经放过超限·饮鸩(zx.dg_ol2 = 1) -> 这一下右键放的是第二形态
#   ★ 必须排在冷却检查**之前** ★ 两段共用同一条 80 秒冷却, 再走一次 check
#     第二段就永远放不出来(玩家看到的就是"用了没反应")。
#   ol_second 自己判"血量 > 60%", 不管成不成都会把 #dg2 置 1 (= 这一下已被它接管),
#   外面的 cast 直接收工, 不会回头又放一遍第一形态。
scoreboard players set #dg2 zx.meta 0
execute if score #dg_ol zx.meta matches 1 if score @s zx.dg_ol2 matches 1 run function sweetdream:equipment/axe/draught/ol_second
execute if score #dg2 zx.meta matches 1 run return 0

# ② 只读检查: 冷却 + 魔力 160
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:draught",mana:160.0}
execute if score #dg_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 360.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"饮鸩冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} if score #dg_ol zx.meta matches 0 run tellraw @s [{"text":"魔力不足（需要 160）","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} if score #dg_ol zx.meta matches 1 run tellraw @s [{"text":"魔力不足（需要 360）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 160 / 360
data modify storage manacore:in arg set value {uuid:"",value:160.0}
execute if score #dg_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 360.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} if score #dg_ol zx.meta matches 0 run tellraw @s [{"text":"魔力不足（需要 160）","color":"red"}]
execute if data storage manacore:out r{success:0b} if score #dg_ol zx.meta matches 1 run tellraw @s [{"text":"魔力不足（需要 360）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 80 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:draught",cooldown_seconds:80.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 先撤掉上一轮残留的加成(防叠加)
execute if score @s zx.dg_buf matches 1.. run function sweetdream:equipment/axe/draught/strip
execute if score @s zx.dg_buf2 matches 1.. run function sweetdream:equipment/axe/draught/ol_strip

# ⑥ 记自伤前的血量(×10 = 0.1 精度)
execute store result score #dg_b zx.meta run data get entity @s Health 10

# ⑦ 自伤 = 当前最大生命 ×0.8(读面板 max_health ×10, 再 ×8 ÷10)
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #dg_mh zx.meta 0
execute store result score #dg_mh zx.meta run data get storage manacore:out r.value 10
scoreboard players operation #dg_hit zx.meta = #dg_mh zx.meta
scoreboard players operation #dg_hit zx.meta *= #8 zx.meta
scoreboard players operation #dg_hit zx.meta /= #10 zx.meta

data modify storage zx:in arg set value {target:"@s",damage:0.0}
execute store result storage zx:in arg.damage double 0.1 run scoreboard players get #dg_hit zx.meta
function sweetdream:api/damage

# ⑧ 记自伤后的血量, 算**实际**损失(×10 -> ÷10 取整)
#   【超限改口径】文案从"自身**受到的**伤害"改成"**本次伤害数值**" ⇒ 直接用
#     ⑦ 算好的计划值(#dg_hit ÷ 10), 不再看血条前后差 —— 被减伤/被护甲吃掉的部分
#     照样算进加成里。这也是文案"基数: 自身受到的伤害 -> 本次伤害数值"的落地。
execute store result score #dg_a zx.meta run data get entity @s Health 10
scoreboard players operation #dg_lost zx.meta = #dg_b zx.meta
scoreboard players operation #dg_lost zx.meta -= #dg_a zx.meta
execute if score #dg_lost zx.meta matches ..0 run scoreboard players set #dg_lost zx.meta 0
scoreboard players operation #dg_lost zx.meta /= #10 zx.meta
scoreboard players operation #dg_plan zx.meta = #dg_hit zx.meta
scoreboard players operation #dg_plan zx.meta /= #10 zx.meta
execute if score #dg_ol zx.meta matches 1 run scoreboard players operation #dg_lost zx.meta = #dg_plan zx.meta

# ⑨ 加成 = 实际受到的伤害(写进 base_attack; 账本 zx.dg_buf 同值)
scoreboard players operation @s zx.dg_buf = #dg_lost zx.meta
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #dg_lost zx.meta
function manacore:api/stats/add

# ⑩ 计时 10 秒(超限 12 秒) + 表现
scoreboard players set @s zx.dg_on 10
execute if score #dg_ol zx.meta matches 1 run scoreboard players set @s zx.dg_on 12
# 超限: 打完这一发就"解锁第二形态" —— 血量 >60% 时再按一次右键进第二形态(见 ol_second)
execute if score #dg_ol zx.meta matches 1 run scoreboard players set @s zx.dg_ol2 1
execute at @s run particle minecraft:item{count:6,item:{id:"minecraft:fermented_spider_eye"}} ~ ~1 ~ 0.4 0.4 0.4 0.05 12 normal
execute at @s run playsound minecraft:entity.generic.drink player @a ~ ~ ~ 0.9 0.7
execute unless score #dg_ol zx.meta matches 1 run tellraw @s [{"text":"饮鸩: 以 ","color":"dark_red"},{"score":{"name":"#dg_lost","objective":"zx.meta"},"color":"red"},{"text":" 点生命的代价, 换来等量的基础攻击力(10 秒)","color":"dark_red"}]
execute if score #dg_ol zx.meta matches 1 run tellraw @s [{"text":"饮鸩: 以 ","color":"dark_red"},{"score":{"name":"#dg_lost","objective":"zx.meta"},"color":"red"},{"text":" 点生命的代价, 换来等量的基础攻击力(12 秒)","color":"dark_red"}]
execute if score #dg_ol zx.meta matches 1 run tellraw @s [{"text":"血量高于 60% 时可以再按一次, 改为「每攻击一次: 自伤 10% 最大生命, 基础攻击力 +10%」(最多 4 次)","color":"gray","italic":true}]
