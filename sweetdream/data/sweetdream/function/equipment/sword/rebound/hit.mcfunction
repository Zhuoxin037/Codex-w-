# ============================================================
# sweetdream:equipment/sword/rebound/hit —— 回锋 · 被动攒「断刃」(每次攻击)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/rebound_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【技能原文(必须和这里对上)】
#   "每次攻击时若有 50 及以上魔力则消耗 30 魔力值并为自身附加一层「断刃」（最多 3 层）。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: **每次攻击**(-> 按游戏刻去重, 横扫多命中不重复扣蓝)。
#   ② 目标范围: 自身(攒层)。
#   ③ 次数: 一次攻击最多攒一层。
#   ④ 上限 3 层(到顶就不再消耗魔力)。
# 【层数存哪】玩家计分项 zx.rb_blade(0..3), 观察镜里显示为「断刃 N/3」(登记在 lib/reg/build 的 layer 表)。
# 【数值改哪】门槛 50 = 下面的 ..49; 消耗 30 = value:30.0; 上限 3 = 下面的 matches 3..。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/rebound_hit
# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----
#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部
#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。
#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 武器门控: 主手或副手是回锋才继续
scoreboard players set #rb_ok zx.meta 0
execute if items entity @s weapon.mainhand iron_sword[custom_data~{zx:["rebound"]}] run scoreboard players set #rb_ok zx.meta 1
execute if items entity @s weapon.offhand iron_sword[custom_data~{zx:["rebound"]}] run scoreboard players set #rb_ok zx.meta 1
execute unless score #rb_ok zx.meta matches 1 run return 0

# 【★ "每次攻击"去重 ★】同刻已结算过就退出
execute if score @s zx.rb_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.rb_lt = #now manacore.meta

# 层数到顶(3)就不再消耗魔力
execute if score @s zx.rb_blade matches 3.. run return 0

# uuid + 魔力 ≥ 50 ?
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #rb_m zx.meta run data get storage manacore:out r.value 1
execute if score #rb_m zx.meta matches ..49 run return 0

# 消耗 30 魔力
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return 0

# +1 层「断刃」
scoreboard players add @s zx.rb_blade 1

# 表现: 刃身一闪 + 一声清脆的淬火
execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.4 0.6 0.4 0.05 12 normal
execute at @s run playsound minecraft:block.anvil.use player @a ~ ~ ~ 0.4 1.8
