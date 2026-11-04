# ============================================================
# sweetdream:equipment/staff/lucid_illusion/skill —— 清醒与幻觉（法杖·魔导士）主动
# ------------------------------------------------------------
# 【谁调用它】cast 分流器（潜行右键）
# 【文案（用户 2026-11-01 原稿）】
#   魔力 500 · 冷却 100 秒。
#   消耗全部法球。对自身造成一次相当于自身最大生命值 ×0.5 的真实伤害。
#   4 秒后，按自身已损失的生命值结算一次：每损失 20% 生命值生成一个法球；
#   每有一个法球超过上限，则改为生成一个持续 20 秒的额外法球。
# 【★ "4 秒后"是逐秒判的 ★】zx.li_pend 存结算刻，由 second 到点调 settle。
#   （不用 schedule：schedule 出来的函数没有执行者，多人同时放要重新扫人。）
# ============================================================

execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:lucid_illusion",mana:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"清醒与幻觉冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 500）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:500.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:lucid_illusion",cooldown_seconds:100.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ① 消耗全部法球（上限内的 + 额外的）
scoreboard players set @s zx.j_orb 0
scoreboard players set @s zx.li_e1 0
scoreboard players set @s zx.li_e2 0
scoreboard players set @s zx.li_e3 0
scoreboard players set @s zx.li_x 0

# ② 对自身 最大生命 ×0.5 真实伤害
function sweetdream:lib/max_health_score
scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
scoreboard players set #mp_mul zx.meta 500
function sweetdream:lib/math/mul_permille
execute store result storage zx:work li.v double 0.001 run scoreboard players get #mp_out zx.meta
function sweetdream:equipment/staff/lucid_illusion/self_hurt with storage zx:work li

# ③ 排 4 秒后的一次性结算
scoreboard players operation @s zx.li_pend = #now manacore.meta
scoreboard players add @s zx.li_pend 80
scoreboard players set @s zx.li_on 1

execute at @s run particle minecraft:end_rod ~ ~1 ~ 1.0 0.8 1.0 0.1 30 normal
execute at @s run particle minecraft:reverse_portal ~ ~1 ~ 0.8 0.8 0.8 0.06 40 normal
execute at @s run playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 1.0 1.6
