# ============================================================
# fallendream:equipment/staff/intone/skill —— 引声（法杖·歌者）主动：让全部追随者各唱一次
# ------------------------------------------------------------
# 【谁调用它】cast 分流器（潜行右键）
# 【文案·原版】魔力 100 · 冷却 20 秒。使用后使自身全部"追随者"触发一次被动。
#   若自身已醒梦，则额外触发一次合奏（不受上限与冷却限制）。
# 【文案·超限】魔力 160 · 冷却 15 秒; 1 秒后全部追随者**再触发一次**被动并刷新其
#   持续时间; 若本次对生物造成了伤害, 则使其附加「渊海」。
# 【★ 怎么只认"自己的"追随者 ★】追随者身上只存主人 uuid，没有名字。
#   这里给施法者挂临时 tag zx.in_owner，逐个追随者反查主人（lib/u_by），
#   反查到的那个玩家身上若同时带 zx.in_owner 就是自己的 —— 不引入新字段。
# 【★ "1 秒后"用玩家身上的到期刻 + core/tick 每刻扫 ★】schedule 出来的函数没有 @s,
#   要找"是谁放的"只能另立一张 UUID 表; 直接记 zx.in_next = #now + 20 刻,
#   每刻扫一次玩家分数即可(项目里 sr_next / an_2nd 都是这个范式)。
# ============================================================

execute unless score @s zx.job matches 3 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 3 run return fail

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 档位: 普通引声 / 超限引声
scoreboard players set #in_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["intone"],ol:"intone"}] run scoreboard players set #in_ol zx.meta 1

# ② 魔力: 原版 100 / 超限 160
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:intone",mana:100.0}
execute if score #in_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 160.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"引声冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:100.0}
execute if score #in_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 160.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 冷却: 原版 20 秒 / 超限 15 秒
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:intone",cooldown_seconds:20.0,reduce:1b}
execute if score #in_ol zx.meta matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 15.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ④ 第一轮: 全部追随者各唱一次
#   本轮"打到的名单"会被 pulse 抄到 zx.in_vic(见 profession/singer/pulse 末尾),
#   超限用它附加「渊海」。
tag @e[tag=zx.in_vic,distance=0..] remove zx.in_vic
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast
tag @s add zx.j_ally_cast
tag @s add zx.in_owner
execute as @e[tag=zx.j_follower,distance=0..] at @s run function fallendream:equipment/staff/intone/one
tag @s remove zx.in_owner
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast

# ⑤ 已醒梦 → 额外一次合奏（不经上限/冷却）
execute if score @s zx.j_aw matches 1 run function fallendream:profession/singer/duet

# ⑥ 超限: 本轮伤害过的生物附加「渊海」 + 记下"1 秒后再唱一次"
execute if score #in_ol zx.meta matches 1 run function fallendream:equipment/staff/intone/yuanhai
execute if score #in_ol zx.meta matches 1 run scoreboard players operation @s zx.in_next = #now manacore.meta
execute if score #in_ol zx.meta matches 1 run scoreboard players add @s zx.in_next 20

execute at @s run particle minecraft:note ~ ~1 ~ 1.2 0.8 1.2 0.4 24 normal
execute at @s run playsound minecraft:block.note_block.chime player @a ~ ~ ~ 1.0 1.2
