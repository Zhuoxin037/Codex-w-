# ============================================================
# sweetdream:equipment/staff/fallen_dream/attack —— 堕梦: 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】消耗 50 魔力; 伤害 = 自身最大魔力值 ×0.03。
#   每次普攻命中后若其处于「白昼梦」效果则本次伤害变为真实伤害。
# 【"改真伤"怎么实现 ★ 先判后打 ★】法球的伤害不在 ball/hit 里打(那里
#   无条件按 skill 类型打, 拦不住) —— 这里把 dmg 设 0, 算好的伤害放在
#   自定义字段 fdmg 里, 命中后由回调 ball_hit 判「白昼梦」再决定
#   打 sweetdream:true_damage 还是 skill(见 ball_hit)。
#   data 里多出的键(fdmg)会随 fire 的整体灌入一起上球, 回调读得到。
# 【「白昼梦」= 通用标签 zx.status.dream】和「幻昼」那套共用, 不另起名。
# ============================================================

# ① 拿 uuid
# ★ 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)。
#   ★ 必须排在**扣魔力之前**: 拦晚了就成了"扣了蓝但没出手"。
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 50(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fd_attack",mana:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #fd_need zx.meta 0
execute store result score #fd_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#fd_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 50(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#fd_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 最大魔力 ×0.03(超限的伤害乘区在 calc 前由 mod 乘进通道)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球: dmg = 0(ball/hit 不打伤害), 真正的伤害在 fdmg, 命中后回调结算
data modify storage zx:work ball set value {dmg:0.0,style:"fallen_dream",hit:"sweetdream:equipment/staff/fallen_dream/ball_hit",fdmg:0.0}
data modify storage zx:work ball.fdmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
