# ============================================================
# sweetdream:equipment/staff/polarized_light/skill —— 偏振光: 主动技能(潜行右键)
# ------------------------------------------------------------
# 【文案】消耗 80 魔力 / 冷却 20 秒。使用后召唤一个术阵。之后自身持续发射
#   一道光线且每秒对自身 10 格内离自己最近的一个生物造成一次相当于自身
#   当前魔力值 ×0.05 的伤害, 且被锁定的生物获得缓慢Ⅱ效果。该效果持续 5 秒。
# 【"持续发射一道光线"是表现层】伤害走每秒一次的检测(second 驱动 tick);
#   光线本身每刻铺一条真的(见 beam / beam_step, 由 core/tick 每刻驱动) ——
#   原来只做了"两端各一小簇", 2026-10-09 用户要求"持续射向目标生物"。
#   ★ 这道光线照到"自己人的共鸣水晶"时会触发共鸣的"法术穿过"
#     (给水晶打 zx.ch_beam 戳, 见 beam_step ② 与 chime/pass_set)。
# 【状态】zx.pl_t = 还剩几秒(玩家身上)。每秒由 second 驱动 tick:
#   重新锁 10 格内最近 → 伤害 → 缓慢Ⅱ → 粒子 → 倒计时; 到 0 自然结束。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/staff/polarized_light

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①' 超限快照: 手里这把是不是超限版偏振光(三道光/0.5秒/3目标/12格/缓慢Ⅲ全看它)
#   ★ 必须每次都写(0 或 1): second 与 core/tick 的分流选择器都拿它当判据 ——
#     不写的话老玩家身上没这个分数, "zx.pl_ol=0" 匹配不上, 光束直接不跑。
function sweetdream:equipment/staff/polarized_light/is_ol
scoreboard players operation @s zx.pl_ol = #pl_ol zx.meta

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 冷却 + 魔力 80
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:polarized_light",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #pl_need zx.meta 0
execute store result score #pl_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"偏振光冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 80(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 20 秒(超限后 24 秒)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:polarized_light",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/cooldown/start

# ⑤ 召唤术阵(5 秒 = 与效果时长对齐)
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:polarized_light",type:"light",duration_seconds:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/create

# ⑥ 点火: 光束状态 5 秒。★ zx.pl_t 的单位**恒为秒**(坑 120):
#   基础版由 second 每 20 刻调 tick 一次 + 扣 1 秒(共 5 次结算);
#   超限版由 core/tick 的 half 每 10 刻调 tick 一次(共 10 次结算)、每 20 刻扣 1 秒
#   —— 两头都是真的 5 秒, 只有"结算节奏"不同(1 秒 / 0.5 秒)。
scoreboard players set @s zx.pl_t 5
scoreboard players set @s zx.pl_ct 0

# ⑦ 表现
execute at @s run playsound minecraft:block.beacon.power_select player @a ~ ~ ~ 0.7 1.8
