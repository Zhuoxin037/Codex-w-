# ============================================================
# sweetdream:equipment/armor/spine_symbiote/apply_hp —— 最大生命值加/减差值
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   【执行者】玩家
# 【生命上限要改两个地方】
#   ① 面板 max_health —— 技能伤害公式读它, 必须跟着变
#   ② 原版属性 minecraft:max_health —— 真正的血条长度
#   面板那个只是"账本", 不会让血条变长。
# 【属性 id 本件独有】sweetdream:eqp_ss_hp —— 和体外供能装置的
#   sweetdream:eqp_power_hp / eqp_set_hp 分开, 各自摘不打架。
# ============================================================

# ① 面板: 加差值
data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 原版属性: 无条件摘, 再按新账加(幂等, 理由见 apply_armor)
attribute @s minecraft:max_health modifier remove sweetdream:eqp_ss_hp

scoreboard players operation @s zx.ss_hp += #diff zx.meta
execute if score @s zx.ss_hp matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.ss_hp matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.ss_hp
execute if score @s zx.ss_hp matches 1.. run function sweetdream:equipment/armor/spine_symbiote/hp_add with storage zx:work x
