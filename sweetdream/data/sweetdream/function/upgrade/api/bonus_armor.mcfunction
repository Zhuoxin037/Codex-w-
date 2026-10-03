# ============================================================
# sweetdream:upgrade/api/bonus_armor —— 汇总**身上穿着的**四件盔甲上的升级
# ------------------------------------------------------------
# 【执行者】玩家   【出参】zx:out r = {mm:<魔力上限>, mr:<每秒回魔>}
# 【为什么单独一个接口】盔甲的升级是"穿着就生效", 而不在主手 ——
#   bonus_held 只认 SelectedItem, 盔甲得扫 equipment.head/chest/legs/feet 四个槽。
#   1.21.5 里穿戴的东西在**独立的 equipment 复合标签**下(不在 Inventory),
#   空槽是"整个键不存在", 所以每个槽都先归零再 store, 读不到就当 0 条。
# 【多件盔甲怎么算】四件一起汇总, 分级链条仍然按"同系取最高 tier" ——
#   头盔装了 α、胸甲装了 β, 结果就是按 β 算(不是 20+30)。
# 【谁调用它】upgrade/second 每秒一次(加魔力上限 / 发回魔)。
# ============================================================

data modify storage zx:out r set value {mm:0,mr:0}
scoreboard players set #up_mm zx.meta 0
scoreboard players set #up_mr zx.meta 0
scoreboard players set #up_mh zx.meta 0
scoreboard players set #up_mhp zx.meta 0
data remove storage zx:work up_val

data modify storage zx:work sl.slot set value "head"
function sweetdream:upgrade/api/bonus_armor_slot with storage zx:work sl
data modify storage zx:work sl.slot set value "chest"
function sweetdream:upgrade/api/bonus_armor_slot with storage zx:work sl
data modify storage zx:work sl.slot set value "legs"
function sweetdream:upgrade/api/bonus_armor_slot with storage zx:work sl
data modify storage zx:work sl.slot set value "feet"
function sweetdream:upgrade/api/bonus_armor_slot with storage zx:work sl

execute store result storage zx:out r.mm int 1 run scoreboard players get #up_mm zx.meta
execute store result storage zx:out r.mr int 1 run scoreboard players get #up_mr zx.meta
