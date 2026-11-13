# ============================================================
# sweetdream:equipment/bow/ablation/fire —— 消融结算
# ------------------------------------------------------------
# 【执行者】射手(玩家), 由 hook_victim 的 execute on attacker at @s 送进来
# 【前置】受害者已打 zx.ab_v; 命中时带 zx.status.yuanhai; 付账已消费
# 【顺序】改状态前先拍"是否带流火"快照(坑 123: 先拍快照再改状态)
# 【文案逐字】消耗「渊海」并使其受到一次相当于自身最大魔力值 x 0.08 的伤害;
#   若其同时拥有「流火」则额外消耗「流火」并使本次伤害类型变为真实伤害。
# ============================================================

# ⓪ 受害者还在吗
execute unless entity @e[tag=zx.ab_v,limit=1] run return 0

# ① 拍"命中前是否带流火"快照(必须在消耗渊海之前)
scoreboard players set #ab_lh zx.meta 0
execute as @e[tag=zx.ab_v,limit=1] if entity @s[tag=zx.status.liuhuo] run scoreboard players set #ab_lh zx.meta 1

# ② 消耗「渊海」(统一入口; mc.ok=1b, done=0b 表示真摘掉了)
data modify storage zx:work a set value {target:"@e[tag=zx.ab_v,limit=1]",mark:"yuanhai"}
function sweetdream:lib/mark_consume
execute unless data storage zx:work mc{ok:1b,done:0b} run return 0

# ③ 命中前同时带「流火」-> 额外消耗「流火」
execute if score #ab_lh zx.meta matches 1 run data modify storage zx:work a set value {target:"@e[tag=zx.ab_v,limit=1]",mark:"liuhuo"}
execute if score #ab_lh zx.meta matches 1 run function sweetdream:lib/mark_consume

# ④ 算伤害 = 自身(射手)最大魔力值 x 0.08
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ⑤ 投递这一次额外伤害(附加段 => uncapped:1b 绕过同刻受伤冷却)
data modify storage zx:work a set value {target:"@e[tag=zx.ab_v,limit=1]",damage:0.0,type:"sweetdream:skill",uncapped:1b,num:0.0,u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
# 命中前带流火 -> 本次伤害类型变为真实伤害(必须排在 config 覆盖之后)
execute if score #ab_lh zx.meta matches 1 run data modify storage zx:work a.type set value "sweetdream:true_damage"
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.damage set from storage manacore:out r.damage
data modify storage zx:work a.num set from storage zx:work a.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
