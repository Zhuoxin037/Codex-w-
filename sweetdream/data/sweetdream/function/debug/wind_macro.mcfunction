# ============================================================
# sweetdream:debug/wind_macro —— 自检正文(宏参数 {uuid, ok})
# ------------------------------------------------------------
# 【执行者】玩家本人
# 【为什么拆两层】风声加成、伤害记录这些路径都按 UUID 拼, 只能用宏。
# 【显示的数值都先搬进 #dbg_* 计分项】tellraw 的 score 组件读的是"计分板上的
#   某个名字", 直接写 @s 不稳妥; 统一搬成"假玩家"分数再显示(本包面板也是这么做的)。
#   用自己包的 zx.meta, 不去动前置包的 manacore.math 草稿板。
# ============================================================

# ---- 风声 / 回响剩余 ----
scoreboard players operation #dbg_sound zx.meta = @s zx.wg_sound
scoreboard players operation #dbg_aura zx.meta = @s zx.wg_aura
scoreboard players operation #dbg_wmana zx.meta = @s zx.wg_mana
tellraw @s [{"text":"风声        ","color":"gray"},{"score":{"name":"#dbg_sound","objective":"zx.meta"},"color":"white"},{"text":"   回响剩余 ","color":"dark_gray"},{"score":{"name":"#dbg_aura","objective":"zx.meta"},"color":"white"},{"text":" 秒","color":"dark_gray"}]
tellraw @s [{"text":"回响加的最大魔力 ","color":"gray"},{"score":{"name":"#dbg_wmana","objective":"zx.meta"},"color":"aqua"}]

# ---- 「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效) ----
#   ★ 2026-10-07: 原来这里打的是 zx:data wg_bonus."<uuid>"(按 uuid 的一次性槽位),
#     那份槽位已整体去掉 —— 现在读玩家自己的计分项, 不需要宏。
#     2026-10-08: 没有倒计时了(拿到就挂着, 打出一次 mm 技能才清)。
scoreboard players set #dbg_mma zx.meta 0
execute store result score #dbg_mma zx.meta run scoreboard players get @s zx.mm_add
execute if score #dbg_mma zx.meta matches 1.. run tellraw @s [{"text":"最大魔力技能加成 +","color":"gray"},{"score":{"name":"#dbg_mma","objective":"zx.meta"},"color":"light_purple"},{"text":"%（挂着, 打出一次最大魔力值技能后清零）","color":"dark_gray"}]
execute unless score #dbg_mma zx.meta matches 1.. run tellraw @s [{"text":"最大魔力技能加成 无","color":"dark_gray"}]

# ---- 上一次算出来的伤害(排查"到底有没有打出去") ----
$execute if data storage zx:data wg_dbg."$(uuid)".burst run tellraw @s [{"text":"上次爆发每跳 ","color":"gray"},{"nbt":"wg_dbg.\"$(uuid)\".burst","storage":"zx:data","color":"white"}]
$execute if data storage zx:data wg_dbg."$(uuid)".aura run tellraw @s [{"text":"上次回响每跳 ","color":"gray"},{"nbt":"wg_dbg.\"$(uuid)\".aura","storage":"zx:data","color":"white"}]

# ---- 术阵占用 / 魔力 ----
data modify storage manacore:in arg set value {uuid:""}
$data modify storage manacore:in arg.uuid set value "$(uuid)"
function manacore:api/formation/count
tellraw @s [{"text":"术阵占用    ","color":"gray"},{"nbt":"r.count","storage":"manacore:out","color":"light_purple"},{"text":" / ","color":"dark_gray"},{"nbt":"r.limit","storage":"manacore:out","color":"dark_purple"}]

data modify storage manacore:in arg set value {uuid:""}
$data modify storage manacore:in arg.uuid set value "$(uuid)"
function manacore:api/mana/get
tellraw @s [{"text":"魔力        ","color":"gray"},{"nbt":"r.value","storage":"manacore:out","color":"aqua"},{"text":" / ","color":"dark_aqua"},{"nbt":"r.max","storage":"manacore:out","color":"dark_aqua"}]
