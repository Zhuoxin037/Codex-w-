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

# ③ 【2026-10-16 删除】这里原有"上限被摘小后把当前生命夹回来"的一段:
#       execute if score #curhp > #maxhp run execute store result entity @s Health float 1 …
#    —— **整段作废, 已删**。原版禁止用命令写玩家 NBT(`/data` / `/execute store` 对玩家
#    一律抛 `commands.data.entity.invalid` = "Unable to modify player data", 1.21.5 已核实),
#    所以这句(含它更早的 double 版本)从来没生效过。命令层面**无法**夹玩家当前生命。
