# ============================================================
# sweetdream:equipment/sword/myriad/cast —— 万念: 群体爆发(用完切成千散)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/myriad 的奖励函数(右键消耗时, 玩家身份)
# 【文案·基础版】消耗 80 魔力 / 冷却 20 秒。
# 【★ 超限版消耗 180 ★】2026-10-08 用户定稿: 超限·万念 / 超限·千散 两把的耗蓝
#   都抬到 180, 基础版维持 80。数值直接写在 cast 里(由 zx.mq_ol 分流, 见 ④),
#   没有走 overlimit/api/mod —— 理由和超限·流光一样: 本武器的超限是"整段换机制",
#   oldef 的 dmg/mana/cd 三个乘区都是 0(它不是"原技能 ×N 倍", 是另一套技能)。
#   使用后切换为「千散」并对自身 3 格内的全部生物造成一次相当于自身当前魔力值 ×0.1 的伤害。
# 【★ 伤害按"扣完这 80 点之后"的当前魔力算 ★】
#   文案的顺序是"使用后…造成相当于自身当前魔力值的伤害", 那就以**施法之后**
#   魔力条上的读数为准 —— 玩家能自己核对(看一眼剩余魔力 ×0.1 就是伤害)。
#   所以顺序固定为: 扣魔力 -> 起冷却 -> 再算伤害。别把 calc 挪到扣蓝之前。
# 【口径】当前魔力 -> 走"其他倍率"通道(other_mul, 基数默认 = 当前魔力)。
#   ⚠️ 吃不到「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效)
#      —— 那一支只往 mm 通道写, 而这里走 other_mul。
# 【换手为什么不在本函数里做】右键消耗后, 通用回手线(internal/itembackup)
#   会在**下一 tick** 把备份的那把剑塞回手里 —— 本函数里直接 item replace 会被它覆盖,
#   等于白换。所以这里只"预约"(打标签 + 倒计时), 真正换手由 core/tick 里的
#   equipment/sword/myriad/swap 在几 tick 之后执行。
# ------------------------------------------------------------
# 【★ 超限·万念 加在这把上的额外机制(全文照抄自 oldef."myriad".lore)★】
#   使用后切换为【千散】并对自身 3 格内的全部生物造成一次相当于自身当前魔力值
#   ×0.1 的伤害。若攻击到生物则召唤一个半径为 5 格持续 6 秒的领域。之后若自身
#   处于领域中且攻击生物 5 次后则有 2 秒时间可以释放一次特殊技能。本次技能的
#   效果为将【千散】切换回【万念】并对领域内的生物使用一次【千散】的主动技能
#   效果。若原本就为【万念】则改为使用一次【万念】的主动技能且本次伤害提高为
#   相当于自身最大魔力值 ×0.12。若自身没有选择释放此次特殊技能则召唤一个相等
#   的领域，之后召唤一个“剑魂”。
#   —— 逐条对应: ③ 特殊技能窗口 / ⑪ 领域 / ⑭ 公共收尾(剑魂·居合)。
#      剑魂·居合那半写在 oldef."qiansan" 那段描述里, 但说的是"本武器",
#      所以两把刀共用一套(见 myriad/tail)。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/sword/myriad

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 超限判定(后面所有超限机制都靠它开关)
function sweetdream:equipment/sword/myriad/is_ol
scoreboard players operation @s zx.mq_ol = #mq_ol zx.meta

# ③ 【超限】特殊技能窗口: 窗口开着 -> 当场兑现, 不耗蓝、不过冷却
#   ★ 2026-10-08 用户定稿: **释放时不再要求"站在领域里"** ★
#     窗口是"在领域里攻击 5 次"换来的, 兑现时再卡一道"领域还在"就说不通了 ——
#     领域总共才 6 秒, 打满 5 次基本已经到期, 于是窗口开出时 #mq_in 多半是 0,
#     直接落回 ④ 撞上 20 秒冷却, 玩家看到的现象就是"特殊技能被冷却锁死、根本放不出来"。
#     释放范围也不再依赖领域: special_go 优先打领域内的生物, 领域已散则退回自身 3 格。
scoreboard players set #mq_sp zx.meta 0
execute if score @s zx.mq_ol matches 1 if score @s zx.mq_win matches 1.. run scoreboard players set #mq_sp zx.meta 1
execute if score #mq_sp zx.meta matches 1 run function sweetdream:equipment/sword/myriad/special
execute if score #mq_sp zx.meta matches 1 run function sweetdream:equipment/sword/myriad/tail
execute if score #mq_sp zx.meta matches 1 run return 0

# ③-2 【本次口径】万念 = 不按剑魂重复、也不清剑魂 (2026-10-08 用户定稿)
#   `#mq_qs` = "本次打的是不是千散口径", 被两处读:
#     · hit_go  读它决定"技能伤害按剑魂重复 1+N 次"走不走(见 hit_go 头注)
#     · tail    读它决定"清剑魂"走不走(见 tail ④)
#   剑魂整套机制(召唤 / 每魂重复一次 / 清除 / 居合)只写在【千散】那段描述里 ⇒
#   用户定稿"本武器" = 千散, 主动放万念两边都不沾。
#   ★ 位置有讲究: 必须在 ③ 的被动分支**之后** —— 被动那一支走 special_go,
#     由它按手里那把(#mq_isq)自己抄一份, 不能被这里的 0 覆盖掉。
scoreboard players set #mq_qs zx.meta 0

# ④ 只读检查: 冷却 + 魔力(基础 80 / 超限 180)
#   ★ 数额算一次存进 #mq_cost, 后面检查 / 提示 / 扣蓝三处都读它 ★
#     不这么做的话"基础 80 / 超限 180"这条分流要抄三遍, 抄歪一处就是
#     "提示说 180 实际扣 80"这种对不上账的 bug。
scoreboard players set #mq_cost zx.meta 80
execute if score @s zx.mq_ol matches 1 run scoreboard players set #mq_cost zx.meta 180
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:myriad",mana:0.0}
execute store result storage manacore:in arg.mana double 1 run scoreboard players get #mq_cost zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"万念冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#mq_cost","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ⑤ 有目标吗? 没有就整个不放(不扣蓝、不进冷却) —— 和影刃/极光一致
execute at @s unless entity @e[type=!#sweetdream:no_damage,distance=..3] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute at @s unless entity @e[type=!#sweetdream:no_damage,distance=..3] run return fail

# ⑥ 扣魔力(原子的: 不够就一个字节都不扣, 见 api/mana/consume)
#   数额复用 ④ 算好的 #mq_cost(基础 80 / 超限 180), 不另写一份
data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute store result storage manacore:in arg.value double 1 run scoreboard players get #mq_cost zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#mq_cost","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑦ 起冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:myriad",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑧ 【超限】记下"本次之前"的剑魂数 —— 技能结束时清的就是这一批
scoreboard players operation @s zx.mq_base = @s zx.mq_soul

# ⑨ 伤害 = 扣蓝之后的当前魔力 ×0.1(【超限】再乘居合攒下的独立乘区)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.mq_ol matches 1 run function sweetdream:equipment/sword/myriad/ju_boost
function manacore:api/damage/calc
scoreboard players set @s zx.mq_jb 0
execute store result score #mq_echo zx.meta run data get storage manacore:out r.damage

# ⑩ 把 3 格内的目标先冻结成标签再打(范围选择器在宏里会被重算, 先固定更稳)
tag @e[tag=zx.mq_dmg] remove zx.mq_dmg
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.mq_dmg
function sweetdream:equipment/sword/myriad/hit_go

# ⑪ 【超限】攻击到生物了 -> 召唤一个半径 5 格、持续 6 秒的领域
execute if score @s zx.mq_ol matches 1 if entity @e[tag=zx.mq_dmg,limit=1] run function sweetdream:equipment/sword/myriad/domain_make

# ⑫ 表现
execute at @s run particle minecraft:sonic_boom ~ ~1.2 ~ 0 0 0 0.0 1 normal
execute at @s run particle minecraft:sculk_soul ~ ~1 ~ 1.6 0.8 1.6 0.02 40 normal
execute at @s run particle minecraft:dust{color:[0.9,0.15,0.2],scale:1.2} ~ ~1 ~ 1.4 0.8 1.4 0.05 30 normal
execute at @s run playsound minecraft:entity.iron_golem.attack player @a ~ ~ ~ 0.7 1.6
execute at @s run playsound minecraft:block.sculk_catalyst.bloom player @a ~ ~ ~ 0.6 0.9

# ⑬ 预约换手: 千散(方向 1)。等几 tick 让通用回手先跑完(见 myriad/swap)
scoreboard players set @s zx.mq_dir 1
scoreboard players set @s zx.mq_wait 3
tag @s add zx.mq_swap

# ⑭ 【超限】公共收尾: 居合延长/增伤、真实伤害回声、进居合、清剑魂
scoreboard players set #mq_sw zx.meta 1
function sweetdream:equipment/sword/myriad/tail
