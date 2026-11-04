# ============================================================
# sweetdream:equipment/axe/detach/cast —— 脱离（斧·“同生”）：蓄一次以最大生命值结算的攻击
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/detach（右键 consume_item）
# 【文案（用户 2026-11-01 原稿）】
#   消耗魔力 50 · 冷却 20 秒。仅“本我者”可使用。
#   使用后下一次攻击额外造成一次相当于自身最大生命值的伤害，之后切换为“同生体”。
# 【★ 伤害走普通通道 ★】用户 2026-11-01 定：吃护甲/减伤（不是真实伤害）。
#   实现 = 直接投 a.num（不经 calc 的乘区），damage type 用 sweetdream:skill。
# 【★ 切换复用 twin/enter ★】它就是"进入同生体"的既有入口，自带存档/快照/守护。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/detach

execute unless score @s zx.job matches 4 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 4 run return fail

# 仅“本我者”（j_form 0 = 本我者，1 = 同生体）
execute if score @s zx.j_form matches 1 run tellraw @s {"text":"仅“本我者”可使用。","color":"red"}
execute if score @s zx.j_form matches 1 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:detach",mana:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"脱离冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 50）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:detach",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 记下这次要用的基数（最大生命值，毫点）
function sweetdream:lib/max_health_score
scoreboard players operation @s zx.dt_hp = #max_hp zx.meta
scoreboard players set @s zx.dt_arm 1

execute at @s run particle minecraft:dust{color:[0.62,0.12,0.2],scale:1.1} ~ ~1 ~ 0.5 0.9 0.5 0.02 24 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.8 0.7
