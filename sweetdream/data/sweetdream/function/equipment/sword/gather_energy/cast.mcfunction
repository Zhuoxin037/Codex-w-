# ============================================================
# sweetdream:equipment/sword/gather_energy/cast —— 聚能(剑/罕见/魔导士1) 右键主动
# ------------------------------------------------------------
# 【谁调用】进度 sweetdream:equipment/sword/gather_energy(consume_item)
# 【执行者】施法玩家
# 【文案逐字】消耗魔力：50 / 冷却时间：35 秒 / 使用后自身获得一个法球。
#   之后自身每有一个法球则恢复自身 5 %魔力值。
# 【流程】skill/check(mana 50) -> lib/mana/pay -> cooldown/start(35s)
#   -> add_orb 加一个普通法球 -> 按施放后当前 zx.j_orb 个数 ×5% 最大魔力回蓝。
# 【回蓝口径】"5 %魔力值"按 5% 最大魔力值; "每有一个法球"按施放后当前
#   zx.j_orb 个数一次性结算(不逐个法球触发), 走 manacore:api/mana/add(不超上限)。
#   计算: max_mana 读进 #ge_mm(×100), 乘球数, 再以 0.0005 缩放写回 double
#   => value = max_mana × N × 0.05。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/gather_energy
execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 只读检查(魔力 50 + 冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gather_energy",mana:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail

# ② 扣魔力 50
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 起冷却 35 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gather_energy",cooldown_seconds:35.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ④ 获得一个法球(普通法球 = 玩家计分项 zx.j_orb, 内部有 3 个上限)
function sweetdream:profession/mage/add_orb

# ⑤ 按施放后当前法球数 × 5% 最大魔力值回蓝
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #ge_mm zx.meta 0
execute store result score #ge_mm zx.meta run data get storage manacore:out r.value 100
scoreboard players set #ge_n zx.meta 0
scoreboard players operation #ge_n zx.meta = @s zx.j_orb
scoreboard players operation #ge_mm zx.meta *= #ge_n zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.0005 run scoreboard players get #ge_mm zx.meta
function manacore:api/mana/add
