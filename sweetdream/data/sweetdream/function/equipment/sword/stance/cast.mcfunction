# ============================================================
# sweetdream:equipment/sword/stance/cast —— 架势（剑·通用）主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/stance（右键 consume_item）
# 【文案（用户定稿，逐字）】
#   魔力 180   ·   冷却 18 秒
#   使用后 3 秒内自身获得抗性提升3，自身记录受到的伤害总量。结束后对自身3 格内的生物造成一次等同于记录值 50% 的伤害。
# 【链】revoke → lib/uuid → skill/check → lib/mana/pay → cooldown/start
#       → 抗性提升Ⅲ 3 秒 → 开 3 秒窗口(绝对到期刻 zx.stc_until = #now + 60)
# 【记录】受伤事件分发链里的 record.mcfunction 累加 zx.hurt_evt（1 点血 = 1000）
#   —— 与 way_back/on_hurt 同款；挂线见交付清单
# 【结算】core/tick 每刻调 tick.mcfunction，到期算 记录值 ×0.5 并投给 3 格内生物
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/stance

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 只读检查：冷却 + 魔力 180
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:stance",mana:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"架势冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s {"text":"魔力不足（需要 180）","color":"red"}
execute unless data storage manacore:out r{success:1b} run return fail

# 扣魔力 180
data modify storage manacore:in arg set value {uuid:"",value:180.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# 起冷却 18 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:stance",cooldown_seconds:18.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 抗性提升3（amplifier 0-based：2 = Ⅲ），持续 3 秒，隐藏粒子
effect give @s minecraft:resistance 3 2 true

# 开 3 秒窗口：绝对到期刻 = #now + 60；累计清零
scoreboard players set @s zx.stc_on 1
scoreboard players set @s zx.stc_sum 0
scoreboard players operation @s zx.stc_until = #now manacore.meta
scoreboard players add @s zx.stc_until 60
