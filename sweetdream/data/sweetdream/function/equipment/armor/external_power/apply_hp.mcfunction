# ============================================================
# sweetdream:equipment/armor/external_power/apply_hp —— 给生命上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 差值   #src = 1(体外本身, +8) / 2(套装, +15)
# 【生命上限要改两个地方】
#   ① 面板的 max_health —— 技能伤害公式读它, 必须跟着变
#   ② 原版属性 minecraft:max_health —— 真正的血条长度
#   面板那个只是"账本", 不会让血条变长; 想真的耐打就得加原版属性。
# 【原版属性为什么每个来源一个 id】
#   modifier 是按 id 记的, 两个来源各用各的 id, 就能各自加、各自摘, 互不干扰:
#     体外本身 -> sweetdream:eqp_power_hp
#     套装     -> sweetdream:eqp_set_hp
# 【为什么先 remove 再加】modifier 重复 add 同 id 的行为不好依赖, 所以每次
#   先按"旧账"摘掉。remove 只在账本记着加过时才调 —— 本来没有却去 remove
#   会失败, 而失败会截断整个函数。
# ============================================================

# ① 面板: 加差值
data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 原版属性: 先按旧账摘, 再按新账加
execute if score #src zx.meta matches 1 if score @s zx.power_hp matches 1.. run attribute @s minecraft:max_health modifier remove sweetdream:eqp_power_hp
execute if score #src zx.meta matches 2 if score @s zx.set_hp matches 1.. run attribute @s minecraft:max_health modifier remove sweetdream:eqp_set_hp

execute if score #src zx.meta matches 1 run scoreboard players operation @s zx.power_hp += #diff zx.meta
execute if score #src zx.meta matches 2 run scoreboard players operation @s zx.set_hp += #diff zx.meta

execute if score #src zx.meta matches 1 if score @s zx.power_hp matches 8 run attribute @s minecraft:max_health modifier add sweetdream:eqp_power_hp 8 add_value
execute if score #src zx.meta matches 2 if score @s zx.set_hp matches 15 run attribute @s minecraft:max_health modifier add sweetdream:eqp_set_hp 15 add_value
