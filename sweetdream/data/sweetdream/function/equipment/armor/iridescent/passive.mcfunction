# ============================================================
# sweetdream:equipment/armor/iridescent/passive —— 异彩的被动结算
# ------------------------------------------------------------
# 【执行者】玩家(由 second 逐个 as @a 调进来)
# 【文案上写的】
#   ① 自身魔力值上限 +220
#   ② 自身在受到伤害后, 对自身 6 格内至多 3 个生物随机施加两种效果(见 hurt)
# 【本件只管 ①】② 是事件驱动(entity_hurt_player 进度 -> hurt),
#   套装两条都在幻昼那一份里(按脊骨共生的先例, 套装统一放"后做的一件")。
# 【认装备统一用 ~ 部分匹配 + 独有标记】custom_data~{zx:["iridescent"]}
#   用 = (精确匹配)会"多一段少一段就整个对不上"且不报错(踩过两次)。
# 【和脑髓蛭/脊骨共生相反】这一件是**加**上限, 不会把上限算成负数,
#   不需要 lib/mana_floor 兜底。
# ============================================================

# ① 拿 UUID(往面板写东西要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 戴没戴
scoreboard players set #ir_on zx.meta 0
execute if items entity @s armor.head netherite_helmet[custom_data~{zx:["iridescent"]}] run scoreboard players set #ir_on zx.meta 1

# ③ 魔力上限 +220(账本 zx.ir_mana, 只加差值)
scoreboard players set #want zx.meta 0
execute if score #ir_on zx.meta matches 1 run scoreboard players set #want zx.meta 220
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ir_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/iridescent/apply_mana
