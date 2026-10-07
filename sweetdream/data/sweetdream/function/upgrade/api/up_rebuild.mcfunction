# ============================================================
# sweetdream:upgrade/api/up_rebuild —— 敲入时重建 up 列表(同系替换占一槽)
# ------------------------------------------------------------
# 【宏参数】zx:work st {id, x, y, z, ...} = station/api/apply_go 传来的全套
# 【谁调用它】station/api/apply_go(替代旧的"直接 append") —— 2026-10-07 槽位改版:
#   一个系列占一槽, 高级替换低级; 所以不再盲目 append, 而是:
#     ① seen 键集里放进**新石头的系列**
#     ② 把旧 up 列表逐条过一遍, 不属于这个系列的搬进 newlist(保留原顺序)
#     ③ newlist 追加新石头 id, 整体写回(最多 2 条; 兼容旧规则敲出来的 4 条老物品)
# 【为什么不走 data remove 按槽删】"删哪几条"取决于旧条目的**系列名**(动态),
#   而"系列相同的判断"和"按系列写动态键"都只能宏 —— 与其逐槽 if/remove(删中间
#   槽还会让后面槽位前移、索引全变), 不如整体重建一次, 顺序/内容都可控。
# 【执行者】玩家(apply_go 原样传下来)
# ============================================================

# ① seen 键集: 只放新石头的系列
data remove storage zx:work seen
data modify storage zx:work fs.id set value ""
$data modify storage zx:work fs.ser set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/ser_put with storage zx:work fs

# ② 旧条目逐条过(0..3: 兼容旧规则敲出的 4 条; 没有那格就跳过)
data remove storage zx:work newlist
data modify storage zx:work newlist set value []
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run data modify storage zx:work fs.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run function sweetdream:upgrade/api/ser_mark2 with storage zx:work fs
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1] run data modify storage zx:work fs.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1] run function sweetdream:upgrade/api/ser_mark2 with storage zx:work fs
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2] run data modify storage zx:work fs.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2] run function sweetdream:upgrade/api/ser_mark2 with storage zx:work fs
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3] run data modify storage zx:work fs.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3] run function sweetdream:upgrade/api/ser_mark2 with storage zx:work fs

# ③ 追加新石头 + 整体写回
$data modify storage zx:work newlist append value "$(id)"
$data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up set from storage zx:work newlist
