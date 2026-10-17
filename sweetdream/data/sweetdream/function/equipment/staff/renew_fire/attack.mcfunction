# ============================================================
# sweetdream:equipment/staff/renew_fire/attack —— 续火: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文】✦ 普攻   魔力 20 · 伤害 5
#   "每次普攻命中后累计一次，每累计 3 次则恢复自身 1 点生命值。切换武器后清空次数。"
# 【★ 伤害是固定 5 ★】走 custom_damage, 不写任何倍率通道。
# 【"命中累计"怎么接】法球自带命中回调 data.hit -> ball/hit 第 ⑥ 步回调
#   renew_fire/ball_hit(判有没有打到生物) -> reward(计数 + 满 3 回血)。
# 【★ 法杖普攻固定范式 ★】gate -> uuid -> 超限快照 -> skill/check -> mana/consume
#   -> 超限 mod -> damage/calc -> 装球(style + hit 回调) -> equipment/staff/attack。
# ============================================================

# ① 法杖普攻间隔: 0.5 秒(10 刻) —— 必须排在扣魔力之前
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(同批法杖一致; 本件暂无超限石, mod 会直接返回)
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 20(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:rf_attack",mana:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #rf_need zx.meta 0
execute store result score #rf_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#rf_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 20(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#rf_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 固定 5
data modify storage manacore:in arg set value {uuid:"",custom_damage:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(命中生物才累计)
data modify storage zx:work ball set value {dmg:0.0,style:"renew_fire",hit:"sweetdream:equipment/staff/renew_fire/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
