# ============================================================
# sweetdream:debug/worn_slot —— 看一个槽位穿了什么
# ------------------------------------------------------------
# 【宏参数】{l, p}      【执行者】玩家本人
#   l = 槽位中文名(如 "头盔  ")
#   p = 读这个槽位的 NBT 路径前缀(如 Inventory[{Slot:103b}])
# 【★ 槽位路径 ★】1.21.5 的玩家 NBT:
#     equipment.head / chest / legs / feet / offhand — 穿戴的东西全在这里
#     主手 = Inventory 里被选中的那格, 用 `SelectedItem` 读
#   ⚠️ 老版那套 "Inventory[{Slot:103b}] = 头盔" 在 1.21.5 **读不到东西**
#      (玩家 Inventory 里现在只有 0..35 这些背包格), 2026-10-03 踩过。
#   (如果某个槽位明明穿着却显示 "—", 十有八九是这里的路径写错了)
# 【★ 为什么读 zx[0] ★】give 里的 custom_data 是 {zx:["<id>","<部位>"]},
#   第 0 个永远是装备 id —— 这也是"认装备"时 custom_data~{zx:["<id>"]} 认的那一段。
# ============================================================

data remove storage zx:work wn

# ① 把这个槽位的 id 抠出来
$execute if data entity @s $(p).components."minecraft:custom_data".zx[0] run data modify storage zx:work wn.id set from entity @s $(p).components."minecraft:custom_data".zx[0]

# ② 空槽
$execute unless data storage zx:work wn.id run tellraw @s [{"text":"  $(l)","color":"gray"},{"text":"—","color":"dark_gray"}]

# ③ 有东西 -> 交给 name_row 翻译并打印
#   ⚠️ name_row 的宏参数是 {id,l,tail}, 三个都得给全 ——
#      少一个键会让那次函数调用直接失败(而且是静默的), 这一行就不显示。
$data modify storage zx:work wn.l set value "  $(l)"
data modify storage zx:work wn.tail set value ""
execute if data storage zx:work wn.id run function sweetdream:debug/name_row with storage zx:work wn
