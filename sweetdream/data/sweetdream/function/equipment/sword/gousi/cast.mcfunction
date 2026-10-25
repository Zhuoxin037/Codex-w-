# ============================================================
# sweetdream:equipment/sword/gousi/cast —— 钩丝（钻石剑 · 主动）主手右键
# ------------------------------------------------------------
# 【魔力 180 / 冷却 28 秒】
# 【机制】锁定 8 格内最近的一个目标，每 5 刻拉近 0.5 格（最多 12 步 = 6 格）。
#   拉到身前 2 格 → 缓慢Ⅱ 3 秒 + 造成 最大魔力值 ×0.12 的伤害
#                   + 自身下一次"最大魔力值类技能"伤害 +10%
#   没拉到（目标没了 / 撞墙 / 拉满 6 格还没贴身）→ 只造成 最大魔力值 ×0.04，不给加成
# 【★ "下一次最大魔力类技能 +10%" 不用自己写钩子】包内已有 zx.mm_add（百分点）
#   + lib/mm_add/hook_calc（挂在 damage_calc 上、一次性消费）——
#   到位时 `scoreboard players add @s zx.mm_add 10` 即可，语义完全一致。
# 【★ 目标怎么标记】tag 名带 UUID[0]（zx.gs_<own>），只在开锁/收尾各写一次，
#   拉的途中不 add/remove —— 2026-10-20 那条延迟坑就是"每刻给生物写 tag"。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/gousi

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["gousi"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["gousi"]}] run return 0

# ⓪.5 超限分流(2026-10-23 批 K3): 敲过超限石(ol:"gousi")的钩丝, 右键放的是「超限·钩丝」
#   —— 一次锁 8 格内最近的**三个**生物, 每 0.25 秒拉 0.8 格, 拉到位 5 秒缓慢Ⅱ
#   + 最大魔力 ×0.12 + 「下三次技能伤害 +10%」(可叠到 +30%, 三次共享)。
#   ★ 主副手都判, 而且判 ol 的**值**是不是 gousi(照 liuguang/cast ⓪.5 那一课)。
scoreboard players set #gs3_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["gousi"],ol:"gousi"}] run scoreboard players set #gs3_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["gousi"],ol:"gousi"}] run scoreboard players set #gs3_ol zx.meta 1
execute if score #gs3_ol zx.meta matches 1 run return run function sweetdream:equipment/sword/gousi/ol_cast

# 没敲超限 -> 把"超限进行中"的标记清掉。
# ★ 为什么非清不可 ★ 上一轮要是超限拉到一半玩家死了(或者换维度把 marker 弄丢),
#   zx.gs3 会留在 1; 下一次普通施法时 pull_go 就会拿它当超限路径去跑三目标那套 ——
#   而 zx:work gs3 早就是空的(uu/u0..u3 全缺), 结算出来的伤害静默变成 1。
execute if score #gs3_ol zx.meta matches 0 run scoreboard players set @s zx.gs3 0

# 先看有没有目标（没有就不扣费）
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gousi",mana:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"钩丝冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 180）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 180）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gousi",cooldown_seconds:28.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ---- 开锁 ----
scoreboard players set #gs_own zx.meta 0
execute store result score #gs_own zx.meta run data get entity @s UUID[0]
scoreboard players operation @s zx.gs_own = #gs_own zx.meta
scoreboard players set @s zx.gs_st 12

data modify storage zx:work gs set value {own:0}
execute store result storage zx:work gs.own int 1 run scoreboard players get #gs_own zx.meta
execute at @s run function sweetdream:equipment/sword/gousi/lock with storage zx:work gs

playsound minecraft:entity.fishing_bobber.throw player @a ~ ~ ~ 0.8 1.1
playsound minecraft:block.chain.step player @a ~ ~ ~ 0.6 1.3
