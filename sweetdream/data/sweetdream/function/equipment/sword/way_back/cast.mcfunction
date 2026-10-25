# ============================================================
# sweetdream:equipment/sword/way_back/cast —— 归途（钻剑 · 双段主动）
# ------------------------------------------------------------
# 【技能原文】
#   魔力 240 · 冷却 40 秒（从放下灯那一刻开始计）
#   "使用后在脚下放下一盏"归途灯"，持续 20 秒。期间再次使用该技能，立即瞬移回"归途灯"处，
#    并恢复这 20 秒内自身所受到伤害的 50%（最多恢复最大生命值的 40%）。若灯存在期间
#    自身生命值从未低于 50%，则瞬移后额外获得 3 秒迅捷Ⅱ。"
# 【两段一条通道】同一个 consume_item：
#   · 没有灯（zx.wb_on 不是 1） → 放灯：扣 240 + 起 40 秒冷却
#   · 有灯                      → 回去：**不扣魔力、不碰冷却**（设计明写"不消耗冷却"）
#   ★ 先判"有没有灯"再判冷却：否则第二段会被自己第一段起的 40 秒冷却挡住。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/way_back

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["way_back"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["way_back"]}] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 已经有灯 → 走第二段
execute if score @s zx.wb_on matches 1 run return run function sweetdream:equipment/sword/way_back/back

# ② 没灯 → 第一段：只读检查
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:way_back",mana:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"归途冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 240
data modify storage manacore:in arg set value {uuid:"",value:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 40 秒（从放灯这一刻计）
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:way_back",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 放灯
function sweetdream:equipment/sword/way_back/lamp

playsound minecraft:block.lantern.place player @a ~ ~ ~ 0.8 1.2
particle minecraft:end_rod ~ ~0.2 ~ 0.3 0.3 0.3 0.02 12 normal
tellraw @s [{"text":"归途灯已放下（20 秒内可再次右键返回）","color":"yellow"}]
