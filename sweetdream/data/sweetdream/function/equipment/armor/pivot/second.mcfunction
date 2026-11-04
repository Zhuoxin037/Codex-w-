# ============================================================
# sweetdream:equipment/armor/pivot/second —— 「枢」术阵位上限 +1（每秒对账）
# ------------------------------------------------------------
# 【执行者】玩家（lib/second 用 as @a 送进来）
# 【文案】自身魔力值上限 +120（在 armor_mana/passive 统一登记）。自身术阵位上限 +1。
# 【★ 为什么改 stats.formation_limit ★】前置包 formation/create 就是按它判满没满
#   （见 manacore internal/formation/create.mcfunction）⇒ 这是唯一正确的入口。
#   **不要**直接改 formations 数组（那是占用，不是上限）。
# 【★ 差值账本 zx.pv_lim ★】0 = 没加 / 1 = 已加 1。重登后玩家记录还在，靠它避免重复叠加。
# ============================================================

execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run function sweetdream:equipment/armor/pivot/off
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run return 0

execute if score @s zx.pv_lim matches 1 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"formation_limit",value:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/add
scoreboard players set @s zx.pv_lim 1
