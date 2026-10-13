# ============================================================
# sweetdream:equipment/sword/crescent/pass3 —— 3 个及以上技能在冷却
# ------------------------------------------------------------
# 【原文】"有 3 个及以上技能正在冷却：缺月不再获得上述效果。普通攻击改为造成
#   最大魔力 ×0.08，但每次攻击随机使一个正在冷却的技能剩余冷却 +1 秒。"
# 【执行者】玩家   【目标】被击中的那一只(zx.victim)
# 【伤害口径】最大魔力 ×0.08 -> max_mana_mul 通道(不再有 ×2/×4)。
# 【随机 +1 秒】在"快捷栏里正在冷却的其它技能"里等概率挑一条 +20 tick:
#   ① 先取 #cr_n(条数);  ② random 0..8 再 % #cr_n -> 均匀落在 [0, n-1];
#   ③ 用 rank 计数器按槽序把"第 #cr_r 条"选中。
#   ★ 为什么用 % —— "随机数取模"是这里唯一能"等概率挑到真正在冷却的那条"的写法
#     (不能拿宏参数当列表下标, 见坑 129; 也不能把 score 塞进 NBT 路径)。
# ============================================================

# ① 追加伤害: 最大魔力 ×0.08
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

data modify storage zx:in arg set value {target:"@e[tag=zx.victim]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# ② 随机挑一条正在冷却的技能
execute store result score #cr_r zx.meta run random value 0..8
scoreboard players operation #cr_r zx.meta %= #cr_n zx.meta
scoreboard players set #cr_rk zx.meta 0

function sweetdream:equipment/sword/crescent/slot {slot:0}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:1}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:2}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:3}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:4}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:5}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:6}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:7}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

function sweetdream:equipment/sword/crescent/slot {slot:8}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:20}
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run data modify storage manacore:in arg.skill set from storage zx:work cr.s
execute if score #cr_hit zx.meta matches 1 if score #cr_rk zx.meta = #cr_r zx.meta run function manacore:api/cooldown/increase
execute if score #cr_hit zx.meta matches 1 run scoreboard players add #cr_rk zx.meta 1

execute at @s run particle minecraft:smoke ~ ~1 ~ 0.4 0.5 0.4 0.02 12 normal
execute at @s run playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.5 1.4
