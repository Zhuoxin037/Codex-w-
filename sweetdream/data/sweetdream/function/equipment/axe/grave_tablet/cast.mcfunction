# ============================================================
# sweetdream:equipment/axe/grave_tablet/cast —— 断碑（下界斧 · 主动技能）
# ------------------------------------------------------------
# 【触发】主手右键（consume_item）。
# 【技能原文】
#   魔力 300 · 冷却 45 秒
#   "向准星方向砸出一道长 6 格的裂口，对裂口上及两侧 1.5 格内的全部生物造成相当于
#    自身基础攻击力 ×4 的真实伤害。若目标护甲值不低于 15，该次伤害提高 80%。
#    每命中一个生物，本技能的冷却时间减少 6 秒，单次最多减少 30 秒。"
# 【四要素】
#   ① 触发：右键。
#   ② 范围：长 6 格 × 两侧 1.5 格 ⇒ 6 个纵向采样点（1~6 格），每点横向 3 条（-1.5/0/+1.5），
#      判定半径 1.5，覆盖"裂口上及两侧 1.5 格"。
#   ③ 次数：立即 1 次。
#   ④ 时长：无持续（设计明确**不做滞留裂缝** —— fissure 超限已经占了"裂缝内无法离开"）。
# 【★ 真实伤害 ★】a.type 写 sweetdream:true_damage（damage_type 注册表内容，
#   已在世界里注册过；bypasses_armor + bypasses_cooldown，但吃抗性提升）。
#   写的是 **storage 值**，不是命令字面量 —— 类型缺失时只会这一发没伤害，不会作废整个函数。
# 【★ 护甲判定 ★】target 上下文里 `attribute @s minecraft:armor get` 读的是**目标**护甲，
#   含装备与修饰符（与秤星同一口径：读原版属性当前值，不读面板缓存）。
# 【减冷却】只减本技能（45 秒）—— 包内没有可遍历的全局冷却表（见 upgrade/api/cd_tick）。
#   单次最多 -30 秒 = 5 个目标封顶。
# ============================================================
advancement revoke @s only sweetdream:equipment/axe/grave_tablet

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["grave_tablet"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["grave_tablet"]}] run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查：冷却 + 魔力 300
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grave_tablet",mana:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"断碑冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 300）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣 300
data modify storage manacore:in arg set value {uuid:"",value:300.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 300）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 起冷却 45 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:grave_tablet",cooldown_seconds:45.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤ 预结算两档：×4 / ×4 再 +80%（独立乘区 1.8）
data modify storage zx:work gt set value {d4:0.0,d18:0.0,u0:0,u1:0,u2:0,u3:0}

data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work gt.d4 set from storage manacore:out r.damage

data modify storage manacore:in arg set value {uuid:"",attack_mul:4.0,independent_multiplier:1.8,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work gt.d18 set from storage manacore:out r.damage

data modify storage zx:work gt.u0 set from entity @s UUID[0]
data modify storage zx:work gt.u1 set from entity @s UUID[1]
data modify storage zx:work gt.u2 set from entity @s UUID[2]
data modify storage zx:work gt.u3 set from entity @s UUID[3]

# ⑥ 收集裂口上的生物
tag @e[tag=zx.gt_hit] remove zx.gt_hit
execute rotated ~ 0 positioned ^ ^ ^1.0 run function sweetdream:equipment/axe/grave_tablet/probe
execute rotated ~ 0 positioned ^ ^ ^2.0 run function sweetdream:equipment/axe/grave_tablet/probe
execute rotated ~ 0 positioned ^ ^ ^3.0 run function sweetdream:equipment/axe/grave_tablet/probe
execute rotated ~ 0 positioned ^ ^ ^4.0 run function sweetdream:equipment/axe/grave_tablet/probe
execute rotated ~ 0 positioned ^ ^ ^5.0 run function sweetdream:equipment/axe/grave_tablet/probe
execute rotated ~ 0 positioned ^ ^ ^6.0 run function sweetdream:equipment/axe/grave_tablet/probe

# ⑦ 逐个结算（护甲 ≥15 的那只吃 +80% 档），并数命中数
scoreboard players set #gt_n zx.meta 0
execute as @e[tag=zx.gt_hit,distance=..20] at @s run function sweetdream:equipment/axe/grave_tablet/one
tag @e[tag=zx.gt_hit] remove zx.gt_hit

# ⑧ 每命中一个 -6 秒（5 个封顶 = -30 秒）
execute if score #gt_n zx.meta matches 1.. run function sweetdream:equipment/axe/grave_tablet/cd

# ⑨ 表现
execute at @s run playsound minecraft:entity.iron_golem.attack player @a ~ ~ ~ 1.0 0.7
execute at @s run playsound minecraft:block.deepslate.break player @a ~ ~ ~ 1.0 0.8
execute rotated ~ 0 positioned ^ ^ ^3.0 run particle minecraft:block{block_state:"minecraft:polished_deepslate"} ~ ~0.1 ~ 1.6 0.1 1.6 0.02 30 normal
