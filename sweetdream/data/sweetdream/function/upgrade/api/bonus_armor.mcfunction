# ============================================================
# sweetdream:upgrade/api/bonus_armor —— 汇总**身上穿着的**四件盔甲上的升级
# ------------------------------------------------------------
# 【执行者】玩家   【出参】zx:out r = {mm:<魔力上限>, mr:<每秒回魔>, ar:<护甲>, at:<韧性>, hp:<最大生命>}
# 【为什么单独一个接口】盔甲的升级是"穿着就生效", 而不在主手 ——
#   bonus_held 只认 SelectedItem, 盔甲得扫 equipment.head/chest/legs/feet 四个槽。
#   1.21.5 里穿戴的东西在**独立的 equipment 复合标签**下(不在 Inventory),
#   空槽是"整个键不存在", 所以每个槽都先归零再 store, 读不到就当 0 条。
# 【多件盔甲怎么算】四件一起汇总, 分级链条仍然按"同系取最高 tier" ——
#   头盔装了 α、胸甲装了 β, 结果就是按 β 算(不是 20+30)。
# 【谁调用它】upgrade/second 每秒一次(加魔力上限 / 发回魔)。
# ============================================================

data modify storage zx:out r set value {mm:0,mr:0,ar:0,at:0,hp:0,nv:0,rg:0}
# ★ 乘区三样也归零(盔甲不输出它们, 但 bonus_take 现在会读/减/加这三个分数;
#   不归零会残留上一件的值 —— 虽然不影响盔甲的结果, 但会让调试时读数莫名其妙)
scoreboard players set #up_dmg zx.meta 0
scoreboard players set #up_mana zx.meta 0
scoreboard players set #up_cd zx.meta 0
scoreboard players set #up_mm zx.meta 0
scoreboard players set #up_mr zx.meta 0
scoreboard players set #up_mh zx.meta 0
scoreboard players set #up_mhp zx.meta 0
# ★ 2026-10-07 扩: 硬化石(护甲/韧性/生命) + 顺手清掉武器向的 cdex/ms(不输出, 免得攒脏数据)
scoreboard players set #up_ar zx.meta 0
scoreboard players set #up_at zx.meta 0
scoreboard players set #up_hp zx.meta 0
# ★ 2026-10-08 扩: 效果开关(火炬 tc / 沸腾 boil / 夜视 nv / 再生 rg)
scoreboard players set #up_tc zx.meta 0
scoreboard players set #up_boil zx.meta 0
scoreboard players set #up_nv zx.meta 0
scoreboard players set #up_rg zx.meta 0
# ★ 2026-10-12 扩: 神经衰弱(攻速 aspd) —— 武器向, 盔甲不输出, 但 bonus_take 会读/减/加它,
#   不归零会让调试读数莫名其妙(和上面 dmg/mana/cd 同理)。
scoreboard players set #up_aspd zx.meta 0
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
# ★ 硬化石
execute store result storage zx:out r.ar int 1 run scoreboard players get #up_ar zx.meta
execute store result storage zx:out r.at int 1 run scoreboard players get #up_at zx.meta
execute store result storage zx:out r.hp int 1 run scoreboard players get #up_hp zx.meta
# ★ 效果开关(夜视仪 / 生命提升·Ω 的常态再生)
execute store result storage zx:out r.nv int 1 run scoreboard players get #up_nv zx.meta
execute store result storage zx:out r.rg int 1 run scoreboard players get #up_rg zx.meta
