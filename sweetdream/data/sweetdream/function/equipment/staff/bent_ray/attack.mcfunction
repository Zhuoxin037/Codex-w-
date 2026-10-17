# ============================================================
# sweetdream:equipment/staff/bent_ray/attack —— 折径: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文】✦ 普攻   魔力 60 · 伤害 8
#   "每次普攻命中后使其附加「折光」。"
# 【★ 伤害是**固定 8**, 不是倍率 ★】所以走 damage/calc 的 custom_damage 通道,
#   三条倍率通道一条都不写(写了会额外叠一份面板值)。
# 【"命中就附加折光"怎么接】法球自带命中回调 data.hit -> ball/hit 第 ⑥ 步
#   回调 bent_ray/ball_hit(见那个文件)。
# 【★ 这一套是法杖普攻的固定范式 ★】(与 begonia / long_night / wake_bell 同构):
#   gate -> uuid -> 超限快照 -> skill/check -> mana/consume -> 超限 mod -> damage/calc
#   -> 装球(style + hit 回调) -> equipment/staff/attack。
# ============================================================

# ① 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(与同批法杖一致; 本件暂无超限石, mod 会直接返回)
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 60(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:br_attack",mana:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #br_need zx.meta 0
execute store result score #br_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#br_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 60(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#br_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 固定 8(普攻面板)
data modify storage manacore:in arg set value {uuid:"",custom_damage:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(命中即附加「折光」)
data modify storage zx:work ball set value {dmg:0.0,style:"bent_ray",hit:"sweetdream:equipment/staff/bent_ray/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
