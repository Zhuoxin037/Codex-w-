# ============================================================
# sweetdream:debug/raw —— 原始数据(不做任何美化)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/raw   或   /trigger zx.dbg_raw
# 【和 debug/stats 的分工】
#   stats 是**给人看的**(去后缀、翻译成中文、只显示有值的那几行);
#   raw 是**给排查用的** —— 数字原样带 NBT 类型后缀("688.0d"), 因为它要
#   忠实反映存储里的真实类型。对不上号的时候, 两个一起看最快。
# 【它打什么】
#   ① 面板整份(manacore:api/stats/export 导出的副本, 含冷却相关字段)
#   ② manacore 的冷却表(读出来是 技能id -> {end,start,total}, 单位是框架时钟)
#   ③ 6 个槽位上那件物品的 custom_data.zx 原始数组
#   ④ 原版属性
# 【它是只读的】不改任何数据。
#
# 【★ 2026-10-03 修了两处 ★】
#   ① 这个文件原来含 $(uuid), 是**宏函数**, 但 tg_raw 调它时没传宏参数 ——
#      于是它一条命令都不跑(静默, 日志都不报), 屏幕上啥都没有。
#      现在改用前置包接口(api/stats/export / api/cooldown/list)拿数据,
#      uuid 走 manacore:in arg.uuid, **整个文件零宏**, 调用方不用再传参。
#   ② 盔甲/副手原来读 Inventory[{Slot:103b}] 这一类 —— 1.21.5 玩家穿戴的东西
#      在独立的 equipment 复合标签里, 老路径读出来永远是空。改读 equipment.*。
# ============================================================

tellraw @s [{"text":"========== 原始数据 ==========","color":"gold"}]
tellraw @s [{"text":"(数字带 d/f 后缀 = NBT 原始类型, 这是故意的)","color":"dark_gray","italic":true}]

# ------------------------------------------------------------
# ⓪ 先取 uuid(当普通数据用, 不拼进命令文本)
# ------------------------------------------------------------
scoreboard players set #g_reg zx.meta 0
data modify storage manacore:in arg set value {uuid:""}
function manacore:api/player/self_uuid
data modify storage zx:work sd set value {uuid:""}
data modify storage zx:work sd.uuid set from storage manacore:out r.uuid
execute if data storage zx:work sd.uuid unless data storage zx:work sd{uuid:""} run scoreboard players set #g_reg zx.meta 1
execute if score #g_reg zx.meta matches 0 run tellraw @s [{"text":"还没注册完成(uuid 是空的) —— 等一秒再试","color":"red"}]
execute if score #g_reg zx.meta matches 0 run return fail

# ---- ① 面板整份 ----
tellraw @s [{"text":"── 面板(manacore:api/stats/export 的副本) ──","color":"dark_gray"}]
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work sd.uuid
function manacore:api/stats/export
tellraw @s [{"nbt":"r.stats","storage":"manacore:out","color":"white"}]

# ---- ② 冷却表 ----
tellraw @s [{"text":"── 冷却(技能id -> end/start/total, 框架时钟) ──","color":"dark_gray"}]
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work sd.uuid
function manacore:api/cooldown/list
tellraw @s [{"nbt":"r.cooldowns","storage":"manacore:out","color":"white"}]

# ---- ③ 六个槽位的 custom_data.zx ----
tellraw @s [{"text":"── 槽位 custom_data.zx(第 0 个 = 装备 id) ──","color":"dark_gray"}]
data remove storage zx:work rw
execute if data entity @s SelectedItem.components."minecraft:custom_data".zx run data modify storage zx:work rw.main set from entity @s SelectedItem.components."minecraft:custom_data".zx
execute if data entity @s equipment.offhand.components."minecraft:custom_data".zx run data modify storage zx:work rw.off set from entity @s equipment.offhand.components."minecraft:custom_data".zx
execute if data entity @s equipment.head.components."minecraft:custom_data".zx run data modify storage zx:work rw.head set from entity @s equipment.head.components."minecraft:custom_data".zx
execute if data entity @s equipment.chest.components."minecraft:custom_data".zx run data modify storage zx:work rw.chest set from entity @s equipment.chest.components."minecraft:custom_data".zx
execute if data entity @s equipment.legs.components."minecraft:custom_data".zx run data modify storage zx:work rw.legs set from entity @s equipment.legs.components."minecraft:custom_data".zx
execute if data entity @s equipment.feet.components."minecraft:custom_data".zx run data modify storage zx:work rw.feet set from entity @s equipment.feet.components."minecraft:custom_data".zx
tellraw @s [{"nbt":"rw","storage":"zx:work","color":"white"}]

# ---- ④ 原版属性(整数, 没有后缀) ----
tellraw @s [{"text":"── 原版属性(整数) ──","color":"dark_gray"}]
execute store result score #r_atk zx.meta run attribute @s minecraft:attack_damage get
execute store result score #r_hp zx.meta run attribute @s minecraft:max_health get
execute store result score #r_arm zx.meta run attribute @s minecraft:armor get
tellraw @s [{"text":"攻击 ","color":"gray"},{"score":{"name":"#r_atk","objective":"zx.meta"},"color":"white"},{"text":"   生命上限 ","color":"gray"},{"score":{"name":"#r_hp","objective":"zx.meta"},"color":"red"},{"text":"   护甲 ","color":"gray"},{"score":{"name":"#r_arm","objective":"zx.meta"},"color":"aqua"}]

tellraw @s [{"text":"看人话版 -> ","color":"dark_gray","italic":true},{"text":"/trigger zx.dbg_stats","color":"aqua","italic":true}]
