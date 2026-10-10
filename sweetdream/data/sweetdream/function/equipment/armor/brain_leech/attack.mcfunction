# ============================================================
# sweetdream:equipment/armor/brain_leech/attack —— 「超限·脑髓蛭」的攻击叠层
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/brain_leech_attack(player_hurt_entity)
#   —— 带着 damage 条件 `minecraft:is_player_attack`, 所以**只有平A算**
#   (技能伤害是 sweetdream:skill 类型, 触发不了这条进度)。口径与 upgrade/attack 一致。
# 【文案】
#   魔力满后: 每次攻击 +1 层「蛊虫」, 并 +5 秒"上限×0.02"的基础攻击力;
#   「蛊虫」满 10 层 -> 转入消耗模式: 每次攻击 -1 层 且 +10 秒"上限×0.05",
#   **不要求魔力满**。掉到 0 层退出消耗模式、重新累积。(玩家 2026-10-07 定稿)
# 【★ "每次攻击" = 一次平A算一次(命中几只都一样) ★】玩家 2026-10-07 定的措辞口径:
#   文案写「每次攻击(后)」-> 按**攻击次数**算; 文案写「攻击到生物」-> 才按**命中数**算。
#   本件文案是"每次攻击后…并为自身附加一层"/"每次攻击消耗一层", 所以走一次算一次
#   (实现 = 文件末尾那三行按游戏刻去重)。
# 【★ 第一行必须是 revoke ★】奖励函数跑完之前玩家可能又打一下,
#   撤销放在后面会漏掉同一次结算(踩过)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/brain_leech_attack
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 戴着脑髓蛭, 而且戴的是**超限**那顶 —— 两个都得满足
execute unless items entity @s armor.head diamond_helmet[custom_data~{zx:["brain_leech"]}] run return 0
execute unless items entity @s armor.head diamond_helmet[custom_data~{ol:"brain_leech"}] run return 0

# 【★ 同一刻只算一次 ★】这个进度是 `player_hurt_entity` —— **每命中一个生物
#   触发一次**。平A带横扫打 3 只 => 这个函数同一刻跑 3 遍 => 「蛊虫」一下 +3 层、
#   定时加成也刷 3 次。玩家 2026-10-07 口径: "每次攻击(平A)只积攒一个, 不管命中
#   几个生物"。所以按**游戏刻**去重: 这刻已经结算过就直接退出。
#   · 用 #now(框架时钟)而不是别的: 天然免疫暂停/TPS, 且横扫的多次伤害确实同刻。
#   · 没分数的玩家 `if score ... = #now` 直接判失败 => 第一次照样放行。
#   · 放在穿着门控**之后**: 没戴超限脑髓蛭就什么都不做, 也不必写这个时间戳。
#   ★ 以后写"每次攻击"型被动都照这个来; 文案写"攻击到生物"的才该按命中数算。
execute if score @s zx.bl_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.bl_lt = #now manacore.meta

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 读魔力(要用"上限"算加成, 消耗模式还要看满没满)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #mn zx.meta 0
scoreboard players set #mx zx.meta 0
execute store result score #mn zx.meta run data get storage manacore:out r.value
execute store result score #mx zx.meta run data get storage manacore:out r.max

# 消耗模式 -> 消耗分支(不看魔力); 否则要"魔力满"才进累积分支
execute if score @s zx.bl_gm matches 1.. run function sweetdream:equipment/armor/brain_leech/atk_consume
execute if score @s zx.bl_gm matches 0 if score #mx zx.meta matches 1.. if score #mn zx.meta >= #mx zx.meta run function sweetdream:equipment/armor/brain_leech/atk_full
