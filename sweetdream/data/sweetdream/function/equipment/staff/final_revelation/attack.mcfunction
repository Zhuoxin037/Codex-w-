# ============================================================
# sweetdream:equipment/staff/final_revelation/attack —— 终末天启: 普攻
# ------------------------------------------------------------
# 【文案】消耗 60 魔力; 伤害 20。每次普攻后都会积攒一层「圣光」;
#   层数到达 10 层则立即释放一次主动技能, 之后清除「圣光」。
# 【伤害是固定值】不走 damage/calc(没有倍率通道可乘) —— 直接把 20.0
#   装进法球, 照偏振光(6 点)的写法。超限目前不接(全包只有燎原/风行接了)。
# 【形状交给类别默认件】法杖普攻 = 射法球(equipment/staff/attack)。
# 【★ "没分数 ≠ 0" ★】第一条普攻时 zx.fr_light 还没有分数, 所以
#   **先 add 再判**: `add` 会把不存在的分数建成 0 再加 1; 而
#   `if score ... matches ..9` 对"没有分数"是**直接判失败**(会永远不涨)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 魔力 60(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fr_attack",mana:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 60)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 60
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 60)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 固定 20 点伤害装进法球, 交给法杖类默认普攻射出去
data modify storage zx:work ball set value {dmg:20.0,style:"plain"}
function sweetdream:equipment/staff/attack

# ⑤ 攒「圣光」; 满 10 层 -> 自动释放一次主动技能(见 auto_light)
scoreboard players add @s zx.fr_light 1
execute if score @s zx.fr_light matches 10.. run function sweetdream:equipment/staff/final_revelation/auto_light
