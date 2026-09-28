# ============================================================
# sweetdream:equipment/staff/wind_ontheground/attack —— 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】消耗 80 魔力; 伤害 = 自身当前魔力值 ×0.04;
#         每次普攻后自身获得迅捷 III, 持续 1 秒;
#         若自身术阵占用已满, 则本次伤害 ×2.5。
# 【怎么打出去】风行是法杖, 所以普攻形态由**类别**决定 ——
#   交给 sweetdream:equipment/staff/attack(法杖类默认 = 向前射出一颗法球),
#   法球碰到生物或者障碍物就消失, 飞满 30 格也会消失。
#   这里只负责"数值", 形状交给类别默认件, 以后每把法杖都共用它。
# 【伤害什么时候结算】**发射那一瞬间**就算好、塞进法球里带着飞。
#   所以命中之前你换装 / 吃药都不会改这一颗球的伤害 —— 和文案的"本次攻击"一致。
# 【迅捷给在发射时】文案写的是"每次普攻后", 所以一按右键就给, 不等到命中。
# 【伤害怎么算】前置包的公式里 base_attack 可以自己指定,
#   所以"当前魔力 ×0.04"= 把当前魔力当成 base_attack、倍率写 0.04。
#   术阵满的时候用 independent_multiplier 再乘 2.5(独立乘区, 正好干这个)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 魔力 80(普攻不进冷却, 所以不查冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wind_attack",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 80)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 80
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 80)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 术阵满不满?(满则本次伤害 ×2.5, 写进独立乘区)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/check
scoreboard players set #full zx.meta 0
execute if data storage manacore:out r{can_create:0b} run scoreboard players set #full zx.meta 1

# ⑤ 算伤害: 当前魔力 ×0.04 (术阵满再 ×2.5)
data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",base_attack:-1.0,skill_multiplier:0.04,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.base_attack set from storage manacore:out r.value
execute if score #full zx.meta matches 1 run data modify storage manacore:in arg.independent_multiplier set value 2.5
function manacore:api/damage/calc

# ⑥ 每次普攻后: 迅捷 III 1 秒(amplifier 2 = III 级)
#   用"短暂持续"的写法, 松手不打了它自己就没了, 不用手动清。
effect give @s minecraft:speed 1 2 true

# ⑦ 把伤害装进法球, 交给"法杖类默认普攻"射出去
data modify storage zx:work ball set value {dmg:0.0,style:"wind"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack

# ⑧ 提示
execute if score #full zx.meta matches 1 run tellraw @s [{"text":"术阵已满 —— 这一下更重了","color":"light_purple"}]
