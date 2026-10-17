# ============================================================
# sweetdream:equipment/staff/fate_thread/attack —— 命缕: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文】✦ 普攻   魔力 80 · 伤害 1
#   "每次普攻命中后都会在其身上留下持续 5 秒的血色丝线。…"
# 【★ 伤害是固定 1 ★】走 custom_damage, 不写任何倍率通道。
# 【"命中后留丝线 / 命中丝线主人 5 格内的另一只就结算"怎么接】
#   法球自带命中回调 data.hit -> ball/hit 第 ⑥ 步回调 fate_thread/ball_hit。
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

# ② 只读检查: 魔力 80(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:ft_attack",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #ft_need zx.meta 0
execute store result score #ft_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ft_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 80(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ft_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 固定 1
data modify storage manacore:in arg set value {uuid:"",custom_damage:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(留丝线 / 触发结算)
data modify storage zx:work ball set value {dmg:0.0,style:"fate_thread",hit:"sweetdream:equipment/staff/fate_thread/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
