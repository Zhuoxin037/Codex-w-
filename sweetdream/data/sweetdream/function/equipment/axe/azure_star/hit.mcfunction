# ============================================================
# sweetdream:equipment/axe/azure_star/hit —— 苍蓝星 · 被动: 每次平A的钩子
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/azure_star_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【首行 revoke 自己】见 lib/rearm —— 不撤的话只有第一次平A会触发。
# 【技能原文(必须和这里对上)】
#   "每次攻击若自身当前魔力值高于 800，则都有 20% 概率提升 1 倍该武器伤害倍率
#    （不可叠加）。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: **每次攻击**(平A) -> 按游戏刻去重(见下)。
#   ② 目标范围: 自身(没有目标) —— 这是个"给自己攒一个待生效倍率"的被动。
#   ③ 次数: 一次平A掷一次骰子。
#   ④ 时长: 攒到之后**一直挂着**, 直到被本武器的下一次伤害消费掉(见 recalc)。
# 【★ "每次攻击" = 一次平A算一次(命中几只都一样) ★】(玩家 2026-10-07 定稿口径)
#   player_hurt_entity **每命中一只触发一次** —— 不去重的话横扫打 3 只 = 掷 3 次骰子,
#   20% 会变成 1-0.8³ ≈ 49%。所以按游戏刻去重, 用本件自己的计分项 zx.as_lt
#   (每件一个, 不共用 —— 同一次平A可能同时命中多个入口, 共用会互相吞)。
# 【★ 它怎么生效(2026-10-07 玩家定) ★】"增加至技能倍率上, 而使用后消除":
#   本件只负责**把 zx.as_x2 置 1**(待生效的"本武器伤害倍率翻倍");
#   真正的 ×2 落在 recalc(把 manacore:in arg.max_mana_mul ×2)并**当场清零**。
#   面板(观测镜/ stats)两边都能看见它:
#     · 观测镜: layer 表里的「翻倍」段(见 lib/reg/build);
#     · stats : azure_star/scan_mul 把 +100% 写进加算池 -> 折进"最大魔力值技能倍率"行。
# 【★ 不可叠加 ★】已经有 zx.as_x2(=1) 时不再掷 —— 反正结果也是 ×2, 不叠成 ×4。
# 【魔力 > 800 才掷】"高于 800" -> 必须 > 800(不是 ≥)。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/azure_star_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是苍蓝星
scoreboard players set #as_ok zx.meta 0
execute if items entity @s weapon.mainhand netherite_axe[custom_data~{zx:["azure_star"]}] run scoreboard players set #as_ok zx.meta 1
execute if items entity @s weapon.offhand netherite_axe[custom_data~{zx:["azure_star"]}] run scoreboard players set #as_ok zx.meta 1
execute unless score #as_ok zx.meta matches 1 run return 0

# ★ 按游戏刻去重(每次攻击算一次, 不按命中数)
#   放在武器门控**之后**、写戳在掷骰**之前**: 这一下掷没中也要挡住同刻的重复调用。
execute if score @s zx.as_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.as_lt = #now manacore.meta

# ★ 不可叠加: 已经攒着翻倍了就不再掷(攒着的时候再中也没有意义)
execute if score @s zx.as_x2 matches 1.. run return 0

# 当前魔力 > 800? (读 manacore 的当前真值 —— 带夹紧)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #as_m zx.meta run data get storage manacore:out r.value 1
execute if score #as_m zx.meta matches ..800 run return 0

# 20% 概率(取模 5 命中 0 = 1/5) —— 走全局 LCG, 和坐标/攻击节奏脱钩
function sweetdream:lib/rnd
scoreboard players operation #as_r zx.meta = #rnd zx.meta
scoreboard players operation #as_r zx.meta %= #5 zx.meta
execute unless score #as_r zx.meta matches 0 run return 0

# 攒上"本武器伤害倍率翻倍"(待生效, 由 recalc 消费)
scoreboard players set @s zx.as_x2 1
execute at @s run particle minecraft:dust{color:[0.2,0.5,1.0],scale:1.0} ~ ~1 ~ 0.5 0.6 0.5 0.02 12 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.6 1.6
