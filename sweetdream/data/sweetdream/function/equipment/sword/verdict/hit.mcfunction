# ============================================================
# sweetdream:equipment/sword/verdict/hit —— 神裁 · 被动(每次攻击后)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/verdict_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   "每次攻击后若自身有 50 及以上的魔力值，则有 25% 的概率消耗 50 魔力值并对被攻击
#    的生物的 2 格内的全部生物造成相当于自身基础攻击力 ×2 的伤害，并使受到伤害的生物
#    获得虚弱Ⅱ、缓慢Ⅱ及发光效果，持续 8 秒。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: **每次攻击后**(= 一次平A一次, 不是每次命中) -> 必须按游戏刻去重(check atkonce)。
#      理由: player_hurt_entity **每命中一只就触发一次**, 横扫打 3 只 => 同刻跑 3 遍。
#   ② 目标范围: "被攻击的生物的 2 格内的**全部**生物"(以被击者为圆心的 AOE)。
#   ③ 次数: 一次平A掷一次骰子(25% -> %=4 命中 0), 命中则扣 50、打一次、上三层效果。
#   ④ 时长: 虚弱Ⅱ/缓慢Ⅱ/发光 **8 秒**。
# 【被击者怎么拿】lib/victim 钉死"刚才这一下打的是哪一只"(进度 conditions 传不进实体)。
# 【数值改哪】魔力门槛 50 = 下面的 ..49; 概率 25% = %=4; 消耗 50 = value:50.0;
#   倍率 2 = attack_mul; 结算半径 2 = 各选择器; 时长 8 秒 = duration:8。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/verdict_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是神裁才继续
scoreboard players set #vd_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_sword[custom_data~{zx:["verdict"]}] run scoreboard players set #vd_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_sword[custom_data~{zx:["verdict"]}] run scoreboard players set #vd_ok zx.meta 1
execute unless score #vd_ok zx.meta matches 1 run return 0

# 【★ "每次攻击"去重 ★】同刻已经结算过就直接退出(player_hurt_entity 每命中一只触发一次)
#   · 没分数的玩家 `if score ... = #now` 判失败 => 第一次照样放行。
#   · 戳写在武器门控之后(没拿神裁就什么都不做, 也不必写时间戳)。
execute if score @s zx.vd_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.vd_lt = #now manacore.meta

# uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 魔力 ≥ 50 ?
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #vd_m zx.meta run data get storage manacore:out r.value 1
execute if score #vd_m zx.meta matches ..49 run return 0

# 25% 概率(掷骰无论如何都掷, 保持序列连续)
function sweetdream:lib/rnd
scoreboard players operation #vd_r zx.meta = #rnd zx.meta
scoreboard players operation #vd_r zx.meta %= #4 zx.meta
execute unless score #vd_r zx.meta matches 0 run return 0

# 扣 50 魔力
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return 0

# 钉死被击者
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,limit=1] run return 0

# 伤害: 基础攻击力 ×2, 对"被击者 2 格内的全部生物"
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @e[tag=zx.victim,limit=1,distance=..32] run function sweetdream:api/damage

# 效果: 虚弱Ⅱ / 缓慢Ⅱ / 发光, 8 秒(施加给"受到伤害的生物")
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",effect:"minecraft:weakness",duration:8,amplifier:1}
execute at @e[tag=zx.victim,limit=1,distance=..32] run function sweetdream:api/effect
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",effect:"minecraft:slowness",duration:8,amplifier:1}
execute at @e[tag=zx.victim,limit=1,distance=..32] run function sweetdream:api/effect
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",effect:"minecraft:glowing",duration:8,amplifier:0}
execute at @e[tag=zx.victim,limit=1,distance=..32] run function sweetdream:api/effect

# 表现
execute at @e[tag=zx.victim,limit=1,distance=..32] run particle minecraft:end_rod ~ ~1 ~ 0.4 0.5 0.4 0.03 20 normal
execute at @e[tag=zx.victim,limit=1,distance=..32] run playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.5 1.5

# 清理 victim
tag @e[tag=zx.victim] remove zx.victim
