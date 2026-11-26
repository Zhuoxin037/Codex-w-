# ============================================================
# fallendream:equipment/axe/detach/cast —— 脱离（斧·“同生”）：蓄一次以最大生命值结算的攻击
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/axe/detach（右键 consume_item）
# 【文案（用户 2026-11-01 原稿 · 原版）】
#   消耗魔力 50 · 冷却 20 秒。仅“本我者”可使用。
#   使用后下一次攻击额外造成一次相当于自身最大生命值的伤害，之后切换为“同生体”。
# 【文案（用户 2026-11-20 原稿 · 超限）】
#   魔力 150 · 冷却 20 秒
#   仅“本我者”可使用。使用后，下一次攻击额外造成一次相当于自身最大生命值 ×1.5 的
#   伤害，之后切换为“同生体”。若该次命中的生物附有「本质」则消耗1层，使该段技能
#   伤害 +25% 并为本我者提供最大生命值15%的临时生命值，持续5秒。切换后的8秒内，
#   同生体第一次命中该生物时，为本我者恢复15%最大生命值。
# 【★ 伤害走普通通道 ★】用户 2026-11-01 定：吃护甲/减伤（不是真实伤害）。
#   实现 = 直接投 a.num（不经 calc 的乘区），damage type 用 fallendream:skill。
# 【★ 切换复用 twin/enter ★】它就是"进入同生体"的既有入口，自带存档/快照/守护。
# 【★ 超限判定在**施放当刻**快照 ★】zx.dtx_ol 记在玩家身上，之后那一次命中按它走。
#   不能等命中去读手上的物品：那会儿玩家可能已经换了武器，倍率会跟着乱。
# ============================================================

advancement revoke @s only fallendream:equipment/axe/detach

execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail

# 仅“本我者”（j_form 0 = 本我者，1 = 同生体）
execute if score @s zx.j_form matches 1 run tellraw @s {"text":"仅“本我者”可使用。","color":"red"}
execute if score @s zx.j_form matches 1 run return fail

# ===== 超限：魔力 50 → 150（主手 / 副手都认）=====
scoreboard players set #dto_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["detach"],ol:"detach"}] run scoreboard players set #dto_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["detach"],ol:"detach"}] run scoreboard players set #dto_ol zx.meta 1
scoreboard players operation @s zx.dtx_ol = #dto_ol zx.meta
scoreboard players set #dto_mana zx.meta 50
execute if score #dto_ol zx.meta matches 1 run scoreboard players set #dto_mana zx.meta 150

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:detach",mana:0.0}
execute store result storage manacore:in arg.mana double 1 run scoreboard players get #dto_mana zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"脱离冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} if score #dto_ol zx.meta matches 0 run tellraw @s {"text":"魔力不足（需要 50）","color":"red"}
execute if data storage manacore:out r{reason:"mana"} if score #dto_ol zx.meta matches 1 run tellraw @s {"text":"魔力不足（需要 150）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute store result storage manacore:in arg.value double 1 run scoreboard players get #dto_mana zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:detach",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 记下这次要用的基数（最大生命值，毫点）
function fallendream:lib/max_health_score
scoreboard players operation @s zx.dt_hp = #max_hp zx.meta
scoreboard players set @s zx.dt_arm 1

execute at @s run particle minecraft:dust{color:[0.62,0.12,0.2],scale:1.1} ~ ~1 ~ 0.5 0.9 0.5 0.02 24 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.8 0.7
