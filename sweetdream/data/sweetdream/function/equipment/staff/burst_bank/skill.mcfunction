# 决堤：50%当前魔力；每25消耗1格，2..15格；375消耗即可到上限。
# 每一子步从真实玩家位置出发；跨刻快照只保存在本人的控制marker。
execute if score @s zx.bb_on matches 1 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.5 超限分档（2026-10-23 批 K8）
#   突进 15→18 格、穿身 ×0.12→×0.2、落点 ×0.06→×0.15、新增「水流地带」
#   （每秒 消耗×0.08 + 缓慢Ⅰ；自身在水流上得迅捷Ⅰ；12 秒）。
scoreboard players set #bb_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["burst_bank"],ol:"burst_bank"}] run scoreboard players set #bb_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["burst_bank"],ol:"burst_bank"}] run scoreboard players set #bb_ol zx.meta 1

# ①.6 先清上一次残留的水流（同一把杖重放不该叠两组）
data modify storage zx:work owner_arg set from storage zx:data self
function sweetdream:equipment/staff/burst_bank/wet_clear with storage zx:work owner_arg

# ② 冷却检查（魔力自己算）
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:burst_bank",mana:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"决堤冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 读当前魔力，<100 禁放
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #bb_mn zx.meta 0
execute store result score #bb_mn zx.meta run data get storage manacore:out r.value
execute if score #bb_mn zx.meta matches ..99 run tellraw @s [{"text":"魔力不足 100，决堤无法施放","color":"red"}]
execute if score #bb_mn zx.meta matches ..99 run return fail

# ④ 消耗 = 当前魔力 ×50%
scoreboard players set #bb_c zx.meta 0
scoreboard players operation #bb_c zx.meta = #bb_mn zx.meta
scoreboard players operation #bb_c zx.meta /= #2 zx.meta

# ⑤ 距离 = 消耗 ÷ 25（夹 2..15 格；超限上限 18 格）
scoreboard players set #bb_d zx.meta 0
scoreboard players operation #bb_d zx.meta = #bb_c zx.meta
scoreboard players set #bb_k zx.meta 25
scoreboard players operation #bb_d zx.meta /= #bb_k zx.meta
execute if score #bb_d zx.meta matches ..1 run scoreboard players set #bb_d zx.meta 2
scoreboard players set #bb_cap zx.meta 15
execute if score #bb_ol zx.meta matches 1 run scoreboard players set #bb_cap zx.meta 18
execute if score #bb_d zx.meta > #bb_cap zx.meta run scoreboard players operation #bb_d zx.meta = #bb_cap zx.meta

# ⑥ 两段伤害（基础 ×0.12 / ×0.06；超限 ×0.2 / ×0.15）
scoreboard players set #bb_p zx.meta 0
scoreboard players operation #bb_p zx.meta = #bb_c zx.meta
scoreboard players operation #bb_p zx.meta *= #3 zx.meta
scoreboard players operation #bb_p zx.meta *= #4 zx.meta
scoreboard players operation #bb_p zx.meta /= #100 zx.meta
execute if score #bb_ol zx.meta matches 1 run scoreboard players operation #bb_p zx.meta = #bb_c zx.meta
execute if score #bb_ol zx.meta matches 1 run scoreboard players operation #bb_p zx.meta /= #5 zx.meta

scoreboard players set #bb_l zx.meta 0
scoreboard players operation #bb_l zx.meta = #bb_c zx.meta
scoreboard players operation #bb_l zx.meta *= #3 zx.meta
scoreboard players operation #bb_l zx.meta *= #2 zx.meta
scoreboard players operation #bb_l zx.meta /= #100 zx.meta
execute if score #bb_ol zx.meta matches 1 run scoreboard players operation #bb_l zx.meta = #bb_c zx.meta
execute if score #bb_ol zx.meta matches 1 run scoreboard players operation #bb_l zx.meta *= #15 zx.meta
execute if score #bb_ol zx.meta matches 1 run scoreboard players operation #bb_l zx.meta /= #100 zx.meta

# ⑥.5 水流每秒伤害 = 消耗 ×0.08（只给超限用）
scoreboard players set #bb_w zx.meta 0
scoreboard players operation #bb_w zx.meta = #bb_c zx.meta
scoreboard players operation #bb_w zx.meta *= #8 zx.meta
scoreboard players operation #bb_w zx.meta /= #100 zx.meta

# ⑦ 扣费
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1.0 run scoreboard players get #bb_c zx.meta
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑧ 起冷却 25 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:burst_bank",cooldown_seconds:25.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start


data modify storage zx:work bb set value {uuid:"",pd:0,ld:0,u0:0,u1:0,u2:0,u3:0,yaw:0.0,origin:[],ol:0}
data modify storage zx:work bb.uuid set from storage zx:data self.uuid
execute store result storage zx:work bb.ol int 1 run scoreboard players get #bb_ol zx.meta
execute store result storage zx:work bb.pd int 1 run scoreboard players get #bb_p zx.meta
execute store result storage zx:work bb.ld int 1 run scoreboard players get #bb_l zx.meta
# 水流每秒伤害记在施法者身上（wet_own 每秒读它；finish 才把它激活）
scoreboard players operation @s zx.bb_wd = #bb_w zx.meta
data modify storage zx:work bb.u0 set from entity @s UUID[0]
data modify storage zx:work bb.u1 set from entity @s UUID[1]
data modify storage zx:work bb.u2 set from entity @s UUID[2]
data modify storage zx:work bb.u3 set from entity @s UUID[3]
data modify storage zx:work bb.yaw set from entity @s Rotation[0]
data modify storage zx:work bb.origin set from entity @s Pos
scoreboard players operation @s zx.bb_left = #bb_d zx.meta
scoreboard players operation @s zx.bb_left *= #2 zx.meta
scoreboard players operation @s zx.bb_paid = #bb_c zx.meta
scoreboard players set @s zx.bb_run 0
scoreboard players set @s zx.bb_on 1
function sweetdream:equipment/staff/burst_bank/start with storage zx:work bb
