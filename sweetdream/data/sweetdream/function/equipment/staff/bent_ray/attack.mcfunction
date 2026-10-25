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

# ①.3 超限判定(批 K9): 主/副手任一件是超限·折径
#   超限·普攻: 魔力 60→**80**、固定伤害 8→**20**、「折光」1 层→**最多 3 层**。
#   ★ 层数上限要在**命中回调**里用(mark_zg 的执行者是生物, 读不到玩家的杖)
#     ⇒ 结果塞进**球的 data**(ol), 与五世恶咒 / 堕梦 / 引雷针同一条路。
scoreboard players set #br_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bent_ray"],ol:"bent_ray"}] run scoreboard players set #br_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bent_ray"],ol:"bent_ray"}] run scoreboard players set #br_ol zx.meta 1

# ② 只读检查: 魔力 60(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:br_attack",mana:60.0}
execute if score #br_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 80.0
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
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#br_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 固定 8(超限 20)
data modify storage manacore:in arg set value {uuid:"",custom_damage:8.0}
execute if score #br_ol zx.meta matches 1 run data modify storage manacore:in arg.custom_damage set value 20.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(命中即附加「折光」)
#   ol = 这一发是不是超限版(给 ball_hit → mark_zg 的"折光最多 3 层"用)
data modify storage zx:work ball set value {dmg:0.0,style:"bent_ray",hit:"sweetdream:equipment/staff/bent_ray/ball_hit",ol:0b}
execute if score #br_ol zx.meta matches 1 run data modify storage zx:work ball.ol set value 1b
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
