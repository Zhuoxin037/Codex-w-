# ============================================================
# sweetdream:debug/stats_macro —— 自检正文(宏参数 {uuid, ok})
# ------------------------------------------------------------
# 【执行者】玩家本人
# 【每一块都用现成的公开接口读】能不自己算就不自己算 ——
#   这样"debug 显示的值"和"技能实际用的值"必然一致。
# ============================================================

# ---- 魔力 ----
data modify storage manacore:in arg set value {uuid:""}
$data modify storage manacore:in arg.uuid set value "$(uuid)"
function manacore:api/mana/get
tellraw @s [{"text":"魔力       ","color":"gray"},{"nbt":"r.value","storage":"manacore:out","color":"aqua"},{"text":" / ","color":"dark_gray"},{"nbt":"r.max","storage":"manacore:out","color":"dark_aqua"}]

# ---- 面板属性(整份导出, 一眼看完) ----
$data modify storage manacore:in arg set value {uuid:"$(uuid)"}
function manacore:api/stats/export
tellraw @s [{"text":"面板属性   ","color":"gray"},{"nbt":"r.stats","storage":"manacore:out","color":"white"}]

# ---- 冷却缩减 ----
$data modify storage manacore:in arg set value {uuid:"$(uuid)"}
function manacore:api/cooldown/reduction_get
tellraw @s [{"text":"冷却缩减   ","color":"gray"},{"nbt":"r.value","storage":"manacore:out","color":"yellow"},{"text":"   (0.25 = 缩短 25%)","color":"dark_gray"}]

# ---- 回魔: 基础 + 装备/被动修正, 再乘倍率 ----
function manacore:api/mana/regen/get
tellraw @s [{"text":"回魔/秒    ","color":"gray"},{"text":"( 基础 ","color":"dark_gray"},{"nbt":"r.value","storage":"manacore:out","color":"green"},{"text":"  +  修正合计 ","color":"dark_gray"},{"nbt":"r.bonus","storage":"manacore:out","color":"green"},{"text":" ) × 倍率 ","color":"dark_gray"},{"nbt":"r.multiplier","storage":"manacore:out","color":"green"}]

# ---- 术阵 ----
$data modify storage manacore:in arg set value {uuid:"$(uuid)"}
function manacore:api/formation/count
tellraw @s [{"text":"术阵       ","color":"gray"},{"nbt":"r.count","storage":"manacore:out","color":"light_purple"},{"text":" / ","color":"dark_gray"},{"nbt":"r.limit","storage":"manacore:out","color":"dark_purple"}]

# ---- 装备加成的账本(每个来源各记一笔, 加起来就是面板上多出来的部分) ----
tellraw @s [{"text":"── 装备加成(账本) ──","color":"dark_gray"}]
tellraw @s [{"text":"魔力上限  静脉泵 ","color":"gray"},{"score":{"name":"@s","objective":"zx.pump_mana"},"color":"aqua"},{"text":"   套装 ","color":"gray"},{"score":{"name":"@s","objective":"zx.set_mana"},"color":"aqua"},{"text":"   桂冠 ","color":"gray"},{"score":{"name":"@s","objective":"zx.dio_mana"},"color":"aqua"}]
tellraw @s [{"text":"生命上限  体外 ","color":"gray"},{"score":{"name":"@s","objective":"zx.power_hp"},"color":"red"},{"text":"   套装 ","color":"gray"},{"score":{"name":"@s","objective":"zx.set_hp"},"color":"red"}]

# ---- 风行于大地之上专属 ----
tellraw @s [{"text":"── 风行于大地之上 ──","color":"dark_gray"}]
tellraw @s [{"text":"风声       ","color":"gray"},{"score":{"name":"@s","objective":"zx.wg_sound"},"color":"aqua"},{"text":"   (超过 60 才有额外加成)","color":"dark_gray"}]
tellraw @s [{"text":"回响剩余   ","color":"gray"},{"score":{"name":"@s","objective":"zx.wg_aura"},"color":"aqua"},{"text":" 秒","color":"gray"}]
$execute if data storage zx:data wg_bonus."$(uuid)" run tellraw @s [{"text":"下次技能加成 ","color":"gray"},{"nbt":"wg_bonus.\"$(uuid)\"","storage":"zx:data","color":"light_purple"},{"text":"   (比例, 0.15 = +15%)","color":"dark_gray"}]
$execute unless data storage zx:data wg_bonus."$(uuid)" run tellraw @s [{"text":"下次技能加成 无","color":"dark_gray"}]

# ---- 当前所有冷却 ----
$data modify storage manacore:in arg set value {uuid:"$(uuid)"}
function manacore:api/cooldown/list
tellraw @s [{"text":"── 冷却中 ──","color":"dark_gray"}]
tellraw @s [{"nbt":"r.cooldowns","storage":"manacore:out","color":"white"}]

tellraw @s [{"text":"(面板属性里 max_mana / max_health 只是技能公式读的账本; 真血条看 entity 属性)","color":"dark_gray"}]
