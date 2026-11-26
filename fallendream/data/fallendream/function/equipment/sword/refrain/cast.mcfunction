# ============================================================
# fallendream:equipment/sword/refrain/cast —— 续唱（剑·歌者3）主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/sword/refrain（右键 consume_item）
# 【文案（用户定稿，逐字）】
#   魔力 70   ·   冷却 20 秒
#   使自身全部「追随者」的持续时间 +4 秒。
# 【链】revoke → 职业门控(歌者3) → lib/uuid → skill/check → lib/mana/pay
#       → cooldown/start → extend（全部自身追随者 zx.j_life +80）
# 【样板】equipment/staff/surge_ebb/{extend,extend_go}.mcfunction（+1 秒 = 20 刻）
#   ⇒ +4 秒 = 80 刻；只动自己的：marker 上 data.u0..u3 存主人 UUID 四个 int
# ============================================================

advancement revoke @s only fallendream:equipment/sword/refrain

execute unless score @s zx.job matches 3 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 3 run return fail

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 只读检查：冷却 + 魔力 70
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:refrain",mana:70.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"续唱冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 70）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

# 扣魔力 70
data modify storage manacore:in arg set value {uuid:"",value:70.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# 起冷却 20 秒
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:refrain",cooldown_seconds:20.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 全部自身「追随者」持续时间 +4 秒
function fallendream:equipment/sword/refrain/extend
