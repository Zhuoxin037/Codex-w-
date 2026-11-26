# ============================================================
# fallendream:equipment/staff/magic_theory/burst —— 三发同体后的追加爆炸
# ------------------------------------------------------------
# 【执行者】主人(被 count 用 as @a[tag=zx.ub] 换身份), 坐标在目标身上
# 【半径】基础 3 格 / 超限 4 格 —— 半径是选择器字面量, 只能拆成两条叶子各写一遍
# 【超限·补一颗「导轨」】必须排在伤害结算之后: 先补的话, 万一这次爆炸本身
#   又触发了别的判定, 手里就多出一枚没消耗过的导轨
# ============================================================
function fallendream:lib/uuid
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
particle minecraft:flash ~ ~1 ~ 0 0 0 0 1 force
execute unless score @s zx.mt_ol matches 1 run function fallendream:equipment/staff/magic_theory/area3
execute if score @s zx.mt_ol matches 1 run function fallendream:equipment/staff/magic_theory/area4
data modify storage zx:work a set value {target:"",type:"fallendream:skill",uncapped:1b,u0:0,u1:0,u2:0,u3:0,num:0.0}
data modify storage zx:work a.target set from storage zx:work mt_area.target
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s manacore.u3
data modify storage zx:work a.num set from storage manacore:out r.damage
data modify storage zx:work a.s2_b_num set value {n:0,d:1}
data modify storage zx:work a.s2_b_num set from storage manacore:out r.s2_b_damage
function fallendream:lib/num/plain
function fallendream:internal/attack/submit_skill
# 超限: 追加爆炸结算完, 补一颗「导轨」(回到这一轮的导轨池里)
execute if score @s zx.mt_ol matches 1 run scoreboard players add @s zx.s2_rail 1
