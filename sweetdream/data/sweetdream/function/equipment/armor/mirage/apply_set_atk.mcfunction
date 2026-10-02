# ============================================================
# sweetdream:equipment/armor/mirage/apply_set_atk —— 套装的基础攻击力加成
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负, 范围 0..3)   【执行者】玩家
# 【改两个地方】
#   ① 面板 base_attack —— 技能伤害公式读它, 不改技能吃不到
#   ② 原版属性 minecraft:attack_damage —— 平砍真的变疼
# 【原版属性为什么先摘再加】modifier 是按 id 记的, 同 id 已存在时 add 会
#   失败(wiki 明确写了), 所以必须先摘。这里**无条件摘**: 摘一个不存在的 id
#   只会返回失败, 函数会继续往下跑, 不会截断; 无条件摘才能保证"账本是多少,
#   属性就是多少", 两者不会失同步。
# 【属性 id 本件独有】sweetdream:eqp_mr_set_atk —— 和脑髓蛭的 eqp_bl_atk
#   分开, 各自摘不打架(两件可以同时生效)。
# ============================================================

# ① 面板: 加差值
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 原版属性: 无条件摘, 再按新账加(幂等)
attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_mr_set_atk

# ③ 更新账本, 再按新账加回去(为 0 时不用加, 摘完就等于没加成)
scoreboard players operation @s zx.mr_atk += #diff zx.meta
execute if score @s zx.mr_atk matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.mr_atk matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.mr_atk
execute if score @s zx.mr_atk matches 1.. run function sweetdream:equipment/armor/mirage/set_atk_add with storage zx:work x
