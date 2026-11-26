# ============================================================
# fallendream:equipment/staff/magic_theory/skill —— 主动: 吃球成轨 / 打轨
# ------------------------------------------------------------
# 【三条分支, 顺序不能换】
#   ① 导轨没用完(且 12 秒窗口还在) → 花一枚导轨发射, 不消耗魔力
#   ② 超限·导轨已耗尽、主动仍在冷却 → 80 魔力补一发, 每个冷却期最多两次
#   ③ 正常开新一轮: 消耗全部普通法球成轨
# 【★ 超限档先拍快照】fire / burst 在别的函数里结算, 那时手上可能已经
#   不是这把杖了(burst 还是 as 主人执行的); ② 分支也要用它
# 【★ ② 必须排在 ③ 之前】否则导轨耗尽时会先去扣 200 魔力开新一轮
# ============================================================
execute unless score @s zx.job matches 1 run return fail
scoreboard players set @s zx.mt_ol 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["magic_theory"],ol:"magic_theory"}] run scoreboard players set @s zx.mt_ol 1
execute if score @s zx.s2_rail matches 1.. if score @s zx.s2_rail_end > #now manacore.meta run return run function fallendream:equipment/staff/magic_theory/fire
execute if score @s zx.mt_ol matches 1 unless score @s zx.s2_rail matches 1.. run return run function fallendream:equipment/staff/magic_theory/paid
execute unless score @s zx.j_orb matches 1.. run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
# 魔力: 基础 120 / 超限 200(先写基准, 超限再覆盖 —— 超限判据必须用 @s 身上的快照)
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:magic_theory",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.mt_ol matches 1 run data modify storage manacore:in arg.mana set value 200.0
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.mt_ol matches 1 run data modify storage manacore:in arg.value set value 200.0
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
# 冷却: 基础 65 秒 / 超限 45 秒
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:magic_theory",cooldown_seconds:65.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.mt_ol matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 45.0
function manacore:api/cooldown/start
scoreboard players operation @s zx.s2_rail = @s zx.j_orb
function fallendream:equipment/armor/eagle_hat/orb_before
scoreboard players set @s zx.j_orb 0
function fallendream:equipment/armor/eagle_hat/orb_after
scoreboard players operation @s zx.s2_rail_end = #now manacore.meta
scoreboard players add @s zx.s2_rail_end 240
# 新一轮 = 补射额度重置(「每个技能冷却期间最多两次」)
scoreboard players set @s zx.mt_paid 0
function fallendream:lib/uuid
data modify storage zx:work s2_rail.owner set from storage zx:data self.uuid
execute store result storage zx:work s2_rail.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work s2_rail.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work s2_rail.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work s2_rail.u3 int 1 run scoreboard players get @s manacore.u3
function fallendream:equipment/staff/magic_theory/reset with storage zx:work s2_rail
playsound minecraft:block.respawn_anchor.charge player @s ~ ~ ~ .7 1.4
