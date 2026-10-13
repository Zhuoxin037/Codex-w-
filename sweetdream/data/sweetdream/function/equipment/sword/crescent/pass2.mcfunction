# ============================================================
# sweetdream:equipment/sword/crescent/pass2 —— 2 个技能在冷却
# ------------------------------------------------------------
# 【原文】"有 2 个技能正在冷却：普通攻击在以上基础上再额外造成相当于基础攻击力 ×2 的
#   伤害，并使自身所有技能冷却时间 -0.5 秒。"
# 【执行者】玩家   【目标】被击中的那一只(zx.victim)
# 【伤害口径】"在 ×2 的基础上再 ×2" = 合计 基础攻击力 ×4 -> attack_mul 4.0。
# 【减冷却】"所有技能冷却 -0.5 秒" = 快捷栏里每一条正在冷却的主动技能各 -10 tick
#   (api/cooldown/reduce 只对正在冷却的技能生效)。
# ============================================================

# ① 追加伤害: 基础攻击力 ×4
data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.victim]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ② 自身所有(快捷栏内正在冷却的)技能冷却 -0.5 秒 = 10 tick
function sweetdream:equipment/sword/crescent/slot {slot:0}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:1}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:2}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:3}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:4}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:5}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:6}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:7}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce
function sweetdream:equipment/sword/crescent/slot {slot:8}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:10}
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 run function manacore:api/cooldown/reduce

execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.4 0.5 0.4 0.04 15 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.6
