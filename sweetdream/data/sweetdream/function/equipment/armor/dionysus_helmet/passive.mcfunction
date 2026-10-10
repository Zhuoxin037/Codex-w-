# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/passive —— 魔力上限 +200(以玩家身份)
# ------------------------------------------------------------
# 【文案】被动技能: 自身魔力值上限 +200。
# 【套路和其它护甲一样】认装备 → 算目标值 → 和账本求差 → 只加差值。
#   账本 = zx.dio_mana(每人一份的计分项), 所以穿上加 200、脱下减 200,
#   不会把别的来源(静脉泵、套装)给的加成冲掉。
# 【判定用 ~ 部分匹配 + 独有标记】custom_data~{zx:["dionysus_helmet"]}
#   用 = 是精确比对, 多一段少一段就静默失效(踩过两次); 标记必须是这件装备独有的。
# ============================================================

# ① 拿 UUID(往面板写东西要用)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 戴没戴
scoreboard players set #dio_on zx.meta 0
execute if items entity @s armor.head netherite_helmet[custom_data~{zx:["dionysus_helmet"]}] run scoreboard players set #dio_on zx.meta 1

# ③ 目标值: 基础 200 / 超限 240(超限·狄俄尼索斯之桂冠: "自身魔力上限+240"),
#   再和账本求差
scoreboard players set #want zx.meta 0
execute if score #dio_on zx.meta matches 1 run scoreboard players set #want zx.meta 200
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["dionysus_helmet"],ol:"dionysus_helmet"}] run scoreboard players set #want zx.meta 240
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.dio_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/dionysus_helmet/apply_mana
