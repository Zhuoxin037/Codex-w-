# ============================================================
# sweetdream:equipment/staff/intone/skill —— 引声（法杖·歌者）主动：让全部追随者各唱一次
# ------------------------------------------------------------
# 【谁调用它】cast 分流器（潜行右键）
# 【文案】魔力 100 · 冷却 20 秒。使用后使自身全部“追随者”触发一次被动。
#   若自身已醒梦，则额外触发一次合奏（不受上限与冷却限制）。
# 【★ 怎么只认"自己的"追随者 ★】追随者身上只存主人 uuid，没有名字。
#   这里给施法者挂临时 tag zx.in_owner，逐个追随者反查主人（lib/u_by），
#   反查到的那个玩家身上若同时带 zx.in_owner 就是自己的 —— 不引入新字段。
# ============================================================

execute unless score @s zx.job matches 3 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 3 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:intone",mana:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"引声冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 100）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:100.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:intone",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 允许追随者的脉冲把伤害记到施法者名下（pulse 里认 zx.j_ally_cast）
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast
tag @s add zx.j_ally_cast
tag @s add zx.in_owner
execute as @e[tag=zx.j_follower,distance=0..] at @s run function sweetdream:equipment/staff/intone/one
tag @s remove zx.in_owner
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast

# 已醒梦 → 额外一次合奏（不经上限/冷却）
execute if score @s zx.j_aw matches 1 run function sweetdream:profession/singer/duet

execute at @s run particle minecraft:note ~ ~1 ~ 1.2 0.8 1.2 0.4 24 normal
execute at @s run playsound minecraft:block.note_block.chime player @a ~ ~ ~ 1.0 1.2
