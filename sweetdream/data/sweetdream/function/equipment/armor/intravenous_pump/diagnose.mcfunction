# ============================================================
# sweetdream:equipment/armor/intravenous_pump/diagnose —— 装备被动自检
# ------------------------------------------------------------
# 【用法】/function sweetdream:equipment/armor/intravenous_pump/diagnose
# 【它打印】两个账本 + 当前魔力/上限 + 当前生命/上限。
#   穿上/脱下装备之后跑一次, 看账本有没有跟着变 —— 这是最快的定位方式:
#     账本一直是 0  -> "认装备"那步没匹配上(custom_data 对不上)
#     账本对了但数值没变 -> 面板写入那步出问题
# ============================================================

function sweetdream:lib/uuid

tellraw @s [{"text":"===== 装备被动自检 =====","color":"gold"}]
tellraw @s [{"text":"魔力上限账本   静脉泵 ","color":"gray"},{"score":{"name":"@s","objective":"zx.pump_mana"},"color":"aqua"},{"text":"   套装 ","color":"gray"},{"score":{"name":"@s","objective":"zx.set_mana"},"color":"aqua"}]
tellraw @s [{"text":"生命上限账本   体外 ","color":"gray"},{"score":{"name":"@s","objective":"zx.power_hp"},"color":"red"},{"text":"   套装 ","color":"gray"},{"score":{"name":"@s","objective":"zx.set_hp"},"color":"red"}]

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
tellraw @s [{"text":"当前魔力 ","color":"gray"},{"nbt":"r.value","storage":"manacore:out"},{"text":" / ","color":"gray"},{"nbt":"r.max","storage":"manacore:out"}]

execute store result score #d_hp zx.meta run data get entity @s Health 1
execute store result score #d_hpmax zx.meta run attribute @s minecraft:max_health get
tellraw @s [{"text":"当前生命 ","color":"gray"},{"score":{"name":"#d_hp","objective":"zx.meta"},"color":"red"},{"text":" / ","color":"gray"},{"score":{"name":"#d_hpmax","objective":"zx.meta"},"color":"red"}]
