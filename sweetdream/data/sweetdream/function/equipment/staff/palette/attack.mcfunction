# ============================================================
# sweetdream:equipment/staff/palette/attack —— 调色盘: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 普攻
#   魔力 50   ·   伤害 1
#   每次普攻命中后都会随机积攒一种颜色。
#   颜色可以叠加，最多同时持有两种颜色。
# 【四要素】
#   触发 = 普通右键(非潜行); 目标范围 = 法球命中的生物; 次数 = 1 发; 时长 = —
# 【伤害】固定 1 点(不走三条倍率通道) -> custom_damage。
# 【"命中后随机攒颜色"怎么接】法球自带命中回调 data.hit; 命中那一刻由
#   ball/hit 第 ⑥ 步回调 palette/ball_hit(见那个文件)。
# 【普攻形态】法杖类默认 = 向前射出一颗法球(sweetdream:equipment/staff/attack)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 50(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:palette_attack",mana:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #pal_need zx.meta 0
execute store result score #pal_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pal_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 50(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pal_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 装球射出去: 固定 1 点伤害 + 命中回调(攒颜色)
data modify storage zx:work ball set value {dmg:1.0,style:"plain",hit:"sweetdream:equipment/staff/palette/ball_hit"}
function sweetdream:equipment/staff/attack
