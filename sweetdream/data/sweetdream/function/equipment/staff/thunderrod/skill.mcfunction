# ============================================================
# sweetdream:equipment/staff/thunderrod/skill —— 引雷针: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 150 魔力 / 冷却 35 秒。使用后对自身 8 格内至多 3 个生物各降下
#   一道闪电。
# 【超限·引雷针(2026-10-23 批 K9)】魔力 150→**240**(冷却 35 秒不变)、目标 3→**7 只**、
#   每只 1→**3 道**; 每道雷额外附加 **最大魔力 ×0.1** 的伤害; 5 秒内有生物被劈满
#   3 次 ⇒ 主人 12 秒内"下次技能额外再放一次主动"(§5.2 第 11 条: 那一次**无蓝耗、
#   无冷却**)。
#   ★ 三道雷不能同刻连劈(10 tick 无敌帧只吃第一道)⇒ 用 marker 排队 0/10/20 tick,
#     由 core/tick 驱动 pend_go_sk, 与普攻那套 pend 同形态。
# 【★ 2026-10-13 起: **只降雷**, 不再有"当前魔力 ×0.05"的伤害 ★】
#   与 bolt_atk 同一决定(数值会超模, 用户拍板砍掉), 详见 bolt_atk 头注。
#   所以本函数不再有 calc, 也不再有"先扣魔力后算"那条(坑 152 对本件失效)。
# 【★ 逐目标落雷为什么用 `at` 不用 `as` ★】`at` 只搬位置、执行者始终是玩家,
#   跨武器增益(挂 lib/on_lightning)要按"玩家"的身份读 @s 的分数。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/thunderrod

# ⓪.5 超限判定: 主/副手任一件是超限·引雷针
#   ★ 这一位还要随"排队的雷"跨刻带过去(每道雷结算时要按它决定加不加 ×0.1 附伤)
#     ⇒ 除了这里的 #tr_ol, 还要写进 marker 的 data(ol, **int**)与主人的 zx.tr_ol。
scoreboard players set #tr_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["thunderrod"],ol:"thunderrod"}] run scoreboard players set #tr_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunderrod"],ol:"thunderrod"}] run scoreboard players set #tr_ol zx.meta 1
scoreboard players operation @s zx.tr_ol = #tr_ol zx.meta

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.5 「额外再放一次主动」的增益还有效吗?(超限机制; 原版永远是 0)
#   ★ 过期就当没有并清掉 —— 别让一个 1 永远挂着。
scoreboard players add @s zx.tr_bonus 0
scoreboard players add @s zx.tr_bdue 0
execute if score @s zx.tr_bonus matches 1 if score @s zx.tr_bdue <= #now manacore.meta run scoreboard players set @s zx.tr_bonus 0

# ② 有目标吗? 8 格内至多 3 个(超限 7 个; 一个都没有就整个不放 —— 不扣蓝、不进冷却)
tag @e[tag=zx.tr_t,distance=0..] remove zx.tr_t
execute if score #tr_ol zx.meta matches 0 at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,sort=nearest,limit=3] add zx.tr_t
execute if score #tr_ol zx.meta matches 1 at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,sort=nearest,limit=7] add zx.tr_t
execute unless entity @e[tag=zx.tr_t,distance=0..,limit=1] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[tag=zx.tr_t,distance=0..,limit=1] run return fail

# ③ 只读检查: 冷却 + 魔力(原版 150 / 超限 240)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:thunderrod",mana:150.0}
execute if score #tr_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 240.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"引雷针冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if score #tr_ol zx.meta matches 0 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 150）","color":"red"}]
execute if score #tr_ol zx.meta matches 1 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ④ 扣魔力(150 / 240; 本件已无自身伤害, 这儿纯粹是付费)
data modify storage manacore:in arg set value {uuid:"",value:150.0}
execute if score #tr_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 240.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if score #tr_ol zx.meta matches 0 if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 150）","color":"red"}]
execute if score #tr_ol zx.meta matches 1 if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 35 秒(超限也是 35 秒 —— 文案没改冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:thunderrod",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 逐个目标落雷(位置搬到它脚下, 执行者仍是玩家)
#   ★ 原版 1 道: 直接劈(最多 3 只, 同刻同一只只中一次, 没有无敌帧冲突)。
execute if score #tr_ol zx.meta matches 0 at @e[tag=zx.tr_t,distance=0..] run function sweetdream:equipment/staff/thunderrod/bolt_skill

# ⑥' ★ 超限 3 道: 排 marker, 到期刻 now+0 / +10 / +20(错开无敌帧, 见 skill_q 头注)
#   storage zx:work tr 是这一批 marker 的公共参数(主人 uuid + 档位)。
execute if score #tr_ol zx.meta matches 1 run function sweetdream:equipment/staff/thunderrod/ol_volley

# ⑥'' ★ 增益生效: 额外**再放一次**主动(§5.2 第 11 条: 这一次**无蓝耗、无冷却**) ★
#   ★ 必须排在 ⑦ 清标签**之前** —— 复用的就是这一批 zx.tr_t。
#   ★ 用掉就清 0(文案是"下一次使用技能时" ⇒ 一次性的, 不是 12 秒内次次都多放一次)。
execute if score @s zx.tr_bonus matches 1 run function sweetdream:equipment/staff/thunderrod/ol_extra
execute if score @s zx.tr_bonus matches 1 run scoreboard players set @s zx.tr_bonus 0

# ⑦ 收尾
tag @e[tag=zx.tr_t,distance=0..] remove zx.tr_t
