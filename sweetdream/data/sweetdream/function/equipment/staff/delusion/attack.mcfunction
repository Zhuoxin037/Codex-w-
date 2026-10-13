# ============================================================
# sweetdream:equipment/staff/delusion/attack —— 惑梦: 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】消耗 20 魔力; 伤害 = 自身最大魔力值 ×0.02。
# 【口径】最大魔力值 → 走 max_mana_mul 通道(基数 = 面板最大魔力, 框架自动取)。
#   ★ 2026-10-07 起「风声奖励」并入这条通道的通用加成(风声 / 忘川彼岸 / 无效),
#     由 lib/mm_add/hook_calc 挂在 damage_calc 事件里 —— 所以普攻**也吃得到**
#     (旧版注释说"普攻不吃"是因为当年那份加成只在几个技能里显式调用)。
#   ★ 执行者必须是玩家: 普攻伤害在这里(玩家身份)算好再塞进法球, 所以吃得到。
# 【伤害在发射那一瞬间算好、塞进法球带着飞】(和风行普攻同一套)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 20(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:dl_attack",mana:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #dl_need zx.meta 0
execute store result score #dl_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#dl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 20(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#dl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 最大魔力 ×0.02(超限的伤害乘区在 calc 前由 mod 乘进通道)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.02}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 把伤害装进法球, 交给法杖类默认普攻射出去
data modify storage zx:work ball set value {dmg:0.0,style:"delusion"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
