# ============================================================
# sweetdream:upgrade/api/hp_add —— 最大生命值加/减差值(硬化石)
# ------------------------------------------------------------
# 【入参】#diff = 差值(可正可负)   【执行者】玩家(zx:data self.uuid 已备好)
# 【生命上限要改两个地方】(和脊骨共生/apply_hp 同一套写法)
#   ① 面板 max_health —— 技能伤害公式读它
#   ② 原版属性 minecraft:max_health —— 真正的血条长度
# 【属性 id 本系统独有】sweetdream:upg_hp
# 【顺序】先改面板再改属性: 面板变小是"夹紧当前血"的触发点, 放最后改属性不影响它。
# ============================================================

# ① 面板: 加差值
data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 原版属性: 无条件摘, 再按新账加(幂等, 理由见 armor_add)
attribute @s minecraft:max_health modifier remove sweetdream:upg_hp

scoreboard players operation @s zx.up_hp += #diff zx.meta
execute if score @s zx.up_hp matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.up_hp matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.up_hp
execute if score @s zx.up_hp matches 1.. run function sweetdream:upgrade/api/hp_attr with storage zx:work x
