# ============================================================
# sweetdream:equipment/bow/pierce/fire —— 穿孔结算
# ------------------------------------------------------------
# 【执行者】射手(玩家), 由 hook_victim 的 execute on attacker at @s 送进来
# 【前置】贯穿路径上的全部生物已打 zx.pi_on
# 【文案逐字】对命中的生物额外附加一次相当于自身最大魔力值 x 0.03 的伤害。
# 【一次算、批量投】伤害只依赖射手最大魔力, 每只相同 => 算一次,
#   with_from 用 target 选择器逐个展开, 内部 ob 基准节点保护 zx:work a。
# ============================================================

# ⓪ 走廊里一个目标都没有 -> 收工(贯穿落空是合法结果)
execute unless entity @e[tag=zx.pi_on,limit=1] run return 0

# ① 算伤害 = 自身(射手)最大魔力值 x 0.03
function sweetdream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 对路径上每只各投递一次额外伤害(附加段 => uncapped:1b 绕过同刻受伤冷却)
data modify storage zx:work a set value {target:"@e[tag=zx.pi_on]",damage:0.0,type:"sweetdream:skill",uncapped:1b,num:0.0,u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
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
