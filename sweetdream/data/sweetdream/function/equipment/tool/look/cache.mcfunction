# ============================================================
# sweetdream:equipment/tool/look/cache —— 面板重数据的每秒缓存(以玩家身份执行)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a[tag=test_look_on] run function ...(每秒)
# 【O02 为什么要有它(2026-10-11, spark 剖析结论)】
#   任何 `data ... entity` —— 读也好、if data 也好 —— 都会把整个玩家
#   (54 格背包 + 全部物品组件 + lore)完整序列化成 NBT(NbtPredicate.entityToNbt)。
#   老面板每刻做: 1×Health + 1×SelectedItem.skill + 6×equip_scan(每条都是
#   if data entity / data modify from entity) ⇒ 开着面板 = **每刻最多 14 次全量
#   序列化**。spark 里那条 8~10 秒/分钟的热点主要就是它。
# 【重新分工】装备在身名单(eq)和手持武器 skill 字段改成**每秒缓存**进
#   zx:look cache; render_go(每刻)只读计分板/命令存储 —— 免序列化。
#   面板的显示粒度本来就是秒(v_cd 后缀 s), 观感不变; 换装最多滞后 1 秒。
# 【★ 头注释换行 —— 见下 ② 的判空说明 ★】
# ============================================================

# ① 装备在身名单: 复用 equip_scan(它把 <id> 写进 zx:work eq.<id>), 完了整体搬进缓存
data remove storage zx:work eq
function sweetdream:debug/equip_scan {p:"SelectedItem"}
function sweetdream:debug/equip_scan {p:"equipment.offhand"}
function sweetdream:debug/equip_scan {p:"equipment.head"}
function sweetdream:debug/equip_scan {p:"equipment.chest"}
function sweetdream:debug/equip_scan {p:"equipment.legs"}
function sweetdream:debug/equip_scan {p:"equipment.feet"}
execute if data storage zx:work eq run data modify storage zx:look cache.eq set from storage zx:work eq
execute unless data storage zx:work eq run data remove storage zx:look cache.eq

# ② 手持武器的 skill 字段(观测镜冷却显示的"哪把武器")
#    ★ skill 是**字符串**(skill:"sweetdream:<id>", 见 _gen_batch5) —— 物品谓词
#    `custom_data~{skill:{}}` 测不了字符串键, 所以这里保留原来的
#    `if data entity` 判定(每秒一次, 只对面板玩家, 开销可忽略)。
data remove storage zx:look cache.skill
execute if data entity @s SelectedItem.components."minecraft:custom_data".skill run data modify storage zx:look cache.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill

# ③ 面板"当前生命"(原来 render_go 每刻 data get entity @s Health —— 又是一次全量
#    序列化)。每秒读一次缓存进 zx.hp_show, render_go 每刻只读计分板。
#    ★ zx.hp_c(criterion)只给"活着/死了"门用(账本自愈), 显示值不用它 ——
#      criterion 的刻度(×2 与否)没有先例背书, 别拿来做显示。
scoreboard players set @s zx.hp_show 0
execute store result score @s zx.hp_show run data get entity @s Health
