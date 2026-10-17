# ============================================================
# sweetdream:equipment/armor/candle_step/consume —— 烛跬: 技能消耗状态后回魔
# ------------------------------------------------------------
# 【谁调用它】lib/on_consume_go（技能真的消耗掉一个状态之后；@s = 消耗者本人）
#   调用点已经判过"副手/靴子穿着"，这里再判一次：本文件要能独立测、也不能被别处误调。
# 【文案(lore 逐字)】自身魔力值上限 +90。自身技能消费生物的「夜火」后，恢复 18 点
#   魔力值；消费生物的「流火」后，恢复 8 点魔力值。
# 【入参】zx:work mc.mark = 刚被消耗掉的那个标签名
# 【★ 只认"技能消耗" ★】过滤在 lib/on_consume_go 里做（mc.src == "skill"）——
#   归息/殓丝 那种"装备被动顺手消耗"不该回这份魔力。
# ============================================================

# ① 靴子必须是烛跬
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run return 0

# ② 按消耗掉的是哪一种定回魔量
scoreboard players set #cst_amt zx.meta 0
execute if data storage zx:work mc{mark:"yehuo"} run scoreboard players set #cst_amt zx.meta 18
execute if data storage zx:work mc{mark:"liuhuo"} run scoreboard players set #cst_amt zx.meta 8
execute if score #cst_amt zx.meta matches ..0 run return 0

# ③ 回魔（走前置包接口；uuid 拿不到就收工）
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #cst_amt zx.meta
function manacore:api/mana/add

# ④ 表现：脚下一圈烛火
execute at @s run particle minecraft:flame ~ ~0.2 ~ 0.35 0.1 0.35 0.01 6 normal

# ⑤ ★ 残烛套装(批 15-4): 技能**成功消费夜火**后 -> 基础攻击力 +10% 4 秒 + 3 秒迅捷Ⅱ ★
#   文案(套装段): "自身技能成功消费夜火后，自身基础攻击力 +10%，持续 4 秒，
#   并获得 3 秒迅捷Ⅱ。该效果 8 秒内最多触发一次。"
#   ★ 只认「夜火」★ —— 消费"流火"那一支**不**触发套装(文案只写了夜火)。
#   ★ 排在回魔之后 ★ —— 到这里"技能成功消费"已经确立(② 已按 mark 定过额),
#     套装只是同一事件上的另一份收益。
execute if data storage zx:work mc{mark:"yehuo"} run function sweetdream:equipment/armor/candle_step/set_atk
