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

# ③ 夹当前生命(2026-10-08 补): 上限被摘小(脱下硬化装备)之后, 当前生命可能还停在
#    新上限之上 —— 原版**不会**自动把血扣下来, 会显示成 30/20 这种脏值。
#    只在"当前 > 上限"时动手, 上限变大时条件不成立, 不会误回血。
#    ⚠️ 必须排在 ①② 都做完之后, 才读得到"真正的最终上限"(furnace_core/apply_hp 同款)。
execute store result score #maxhp zx.meta run attribute @s minecraft:max_health get
execute store result score #curhp zx.meta run data get entity @s Health
execute if score #curhp zx.meta > #maxhp zx.meta run execute store result entity @s Health double 1 run scoreboard players get #maxhp zx.meta
