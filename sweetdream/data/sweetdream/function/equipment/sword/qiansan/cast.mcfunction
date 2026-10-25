# ============================================================
# sweetdream:equipment/sword/qiansan/cast —— 千散: 群体爆发(用完切回万念)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/qiansan 的奖励函数(右键消耗时, 玩家身份)
# 【文案·基础版】消耗 80 魔力 / 冷却 20 秒。
# 【★ 超限版消耗 180 ★】和超限·万念同一条口径(2026-10-08 用户定稿): 超限 180、
#   基础 80, 由 zx.mq_ol 分流写在 cast 里(不走 overlimit/api/mod, 理由见 myriad/cast 顶注)。
#   使用后切换为「万念」并对自身 3 格内的全部生物造成一次相当于自身基础攻击力 ×2 的伤害。
# 【和万念是一对】两把是同一把武器的一体两面, 魔力/冷却完全一致(80 / 20 秒,
#   超限后 180 / 20 秒), 只有伤害口径不同: 万念吃**当前魔力**, 千散吃**基础攻击力**。
# 【口径】基础攻击力 -> 走"基础攻击力倍率"通道(attack_mul, 基数 = 面板 base_attack)。
# 【换手为什么不在本函数里做】见 myriad/cast 的第 ⑬ 步注释:
#   通用回手线会在下一 tick 把备份塞回来, 这里直接 replace 会被覆盖。
# ------------------------------------------------------------
# 【★ 超限·千散 加在这把上的额外机制(全文照抄自 oldef."qiansan".lore)★】
#   使用后切换为【万念】并对自身 3 格内的全部生物造成一次相当于自身基础攻击力
#   ×3 的伤害。若攻击到生物则召唤一个“剑魂”（最多为 5 个）。自身每有一个“剑
#   魂”则本武器的技能伤害则重复一次。自身若主动使用了本武器技能则“剑魂”在
#   技能结束后清除（不包含本次技能积攒的“剑魂”），手持切换为其它武器时一并
#   清除。若自身有 5 个“剑魂”且被动或主动使用了该技能则进入 3 秒「居合」状态。
#   动或主动使用了该技能则进入 3 秒「居合」状态。期间每使用技能切换【万念】或
#   【千散】都会使该效果延长一秒并使这两把武器下一次技能伤害提升 20%（独立乘
#   区）。「居合」状态下每切换一次【万念】或【千散】都会对造成了伤害的生物再次
#   造成一次相等的真实伤害。结束后清除“剑魂”。
#   —— 逐条对应: ③ 特殊技能窗口 / ⑨ 倍率 ×2 -> ×3 / ⑪ 剑魂 / ⑭ 公共收尾。
#      "手持切换为其它武器时一并清除"落在 ol_second → soul_lost(按持有状态每秒判)。
#      特殊技能窗口那半写在 oldef."myriad" 那段描述里, 但两把是同一把武器,
#      所以窗口对两把都开(见 myriad/special)。
#   ★ 剑魂只归【千散】(2026-10-08 用户定稿): "本武器"=千散 ⇒ 只有"主动放千散"
#     才清剑魂、只有千散口径的技能伤害才按剑魂重复。主动放万念两边都不沾
#     (老实现按"万念/千散两形态一起算", 用万念会把攒的剑魂全清 —— 已收窄)。
#     落点: cast ③-2 设 #mq_qs=1 / tail ④ 门控 / hit_go 头注。
# 【★ 倍率随超限变 ★】基础版 ×2 / 超限版 ×3, 由 zx.mq_ol 分流。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/sword/qiansan

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 超限判定
function sweetdream:equipment/sword/myriad/is_ol
scoreboard players operation @s zx.mq_ol = #mq_ol zx.meta

# ③ 【超限】特殊技能窗口(和万念同一套, 见 myriad/special)
#   窗口开着就兑现 —— 不耗蓝、不过冷却, 也**不再要求站在领域里**(2026-10-08 用户定稿,
#   理由见 myriad/cast ③: 领域 6 秒, 打满 5 次后基本已散, 卡这一道就等于放不出来)。
scoreboard players set #mq_sp zx.meta 0
execute if score @s zx.mq_ol matches 1 if score @s zx.mq_win matches 1.. run scoreboard players set #mq_sp zx.meta 1
execute if score #mq_sp zx.meta matches 1 run function sweetdream:equipment/sword/myriad/special
execute if score #mq_sp zx.meta matches 1 run function sweetdream:equipment/sword/myriad/tail
execute if score #mq_sp zx.meta matches 1 run return 0

# ③-2 【本次口径】千散 = 按剑魂重复(1+N 次) + 主动放时清剑魂 (2026-10-08 用户定稿)
#   `#mq_qs` = 1, 被两处读: hit_go(重复 1+N 次) / tail ④(清剑魂, 另需非被动)。
#   剑魂整套机制只写在【千散】那段描述里, 用户定稿"本武器" = 千散 ⇒ 只有这一把吃。
#   ★ 位置和万念那份对称: 必须在 ③ 的被动分支**之后**(被动那支由 special_go 自己抄)。
scoreboard players set #mq_qs zx.meta 1

# ④ 只读检查: 冷却 + 魔力(基础 80 / 超限 180)
#   数额算一次存进 #mq_cost, 检查 / 提示 / 扣蓝三处都读它(见 myriad/cast ④ 的说明)
scoreboard players set #mq_cost zx.meta 80
execute if score @s zx.mq_ol matches 1 run scoreboard players set #mq_cost zx.meta 180
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:qiansan",mana:0.0}
execute store result storage manacore:in arg.mana double 1 run scoreboard players get #mq_cost zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"千散冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#mq_cost","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ⑤ 有目标吗? 没有就整个不放
execute at @s unless entity @e[type=!#sweetdream:no_damage,distance=..3] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute at @s unless entity @e[type=!#sweetdream:no_damage,distance=..3] run return fail

# ⑥ 扣魔力(数额复用 ④ 算好的 #mq_cost: 基础 80 / 超限 180)
data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute store result storage manacore:in arg.value double 1 run scoreboard players get #mq_cost zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#mq_cost","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑦ 起冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:qiansan",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑧ 【超限】记下"本次之前"的剑魂数 —— 技能结束时清的就是这一批
scoreboard players operation @s zx.mq_base = @s zx.mq_soul

# ⑨ 伤害 = 基础攻击力 ×3(超限) / ×2(基础), 再乘居合攒下的独立乘区
execute if score @s zx.mq_ol matches 1 run data modify storage manacore:in arg set value {uuid:"",attack_mul:3.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute unless score @s zx.mq_ol matches 1 run data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.mq_ol matches 1 run function sweetdream:equipment/sword/myriad/ju_boost
function manacore:api/damage/calc
scoreboard players set @s zx.mq_jb 0
execute store result score #mq_echo zx.meta run data get storage manacore:out r.damage

# ⑩ 冻结 3 格内的目标再打(按剑魂重复, 见 hit_go)
tag @e[tag=zx.mq_dmg] remove zx.mq_dmg
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.mq_dmg
function sweetdream:equipment/sword/myriad/hit_go

# ⑪ 【超限】攻击到生物了 -> 召唤一个“剑魂”(最多 5 个)
execute if score @s zx.mq_ol matches 1 if entity @e[tag=zx.mq_dmg,limit=1] run function sweetdream:equipment/sword/myriad/soul_gain

# ⑫ 表现(和万念一冷一暖: 那边深红低沉, 这边金白清脆)
execute at @s run particle minecraft:flash ~ ~1.2 ~ 0 0 0 0.0 1 normal
execute at @s run particle minecraft:end_rod ~ ~1 ~ 1.6 0.8 1.6 0.02 40 normal
execute at @s run particle minecraft:dust{color:[1.0,0.85,0.35],scale:1.2} ~ ~1 ~ 1.4 0.8 1.4 0.05 30 normal
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.8 1.7
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.9

# ⑬ 预约换手: 万念(方向 2)
scoreboard players set @s zx.mq_dir 2
scoreboard players set @s zx.mq_wait 3
tag @s add zx.mq_swap

# ⑭ 【超限】公共收尾: 居合延长/增伤、真实伤害回声、进居合、清剑魂
scoreboard players set #mq_sw zx.meta 1
function sweetdream:equipment/sword/myriad/tail
