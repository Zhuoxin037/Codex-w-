# ============================================================
# fallendream:equipment/armor/spirit_sight/passive —— 灵视·每秒
# ------------------------------------------------------------
# 【执行者】玩家(second 用 `as @a at @s` 送进来)
# 【基础版】上限 +70(armor_mana)。8 格内有带「渊海」「流火」「夜火」「白昼梦」
#   「噬心」任一标签的生物 → 使其发光，且自身每秒恢复 1 点魔力值。
# 【超限版】上限 +140(armor_mana)。同样五标签生物 → 发光 + 缓慢Ⅱ，
#   其受到的"最大魔力值相关技能伤害" +24%、护甲值与护甲韧性 −20%，
#   且**每有一只**自身每秒恢复 8 点魔力值。
# 【★ 回魔从"存在即 1 点"变成"每只 8 点" ★】所以必须先**去重计数**:
#   同一只生物可能同时带两个标签, 按标签各加一次就会多数。
#   做法 = 先给命中者打临时标 zx.ss_q, 再按临时标数一次, 数完立刻摘掉。
# 【★ 受击侧 +24% 用"标记"而不是每刻现查 ★】伤害结算(one)在生物身上执行,
#   那里既不该反查玩家(卡顿), 也读不到施法者周围有几件灵视 ⇒ 每秒给范围内的
#   生物打 zx.ss_ol(带 zx.ss_t 到期刻, 3 秒), 受击侧只判这一个标签。
# 【护甲/韧性 −20% 也挂在标记上】进范围就挂 modifier, 出范围由 lib/second 摘。
# ============================================================

# ① 穿着门控 + 档位
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["spirit_sight"]}] run return 0
scoreboard players set #ss_ol zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["spirit_sight"],ol:"spirit_sight"}] run scoreboard players set #ss_ol zx.meta 1

# ② 去重计数: 五标签生物先统一打 zx.ss_q
execute as @e[distance=..8,tag=zx.status.yuanhai] run tag @s add zx.ss_q
execute as @e[distance=..8,tag=zx.status.liuhuo] run tag @s add zx.ss_q
execute as @e[distance=..8,tag=zx.status.yehuo] run tag @s add zx.ss_q
execute as @e[distance=..8,tag=zx.status.dream] run tag @s add zx.ss_q
execute as @e[distance=..8,tag=zx.status.shixin] run tag @s add zx.ss_q
scoreboard players set #ss_n zx.meta 0
execute as @e[distance=..8,tag=zx.ss_q] run scoreboard players add #ss_n zx.meta 1
execute unless score #ss_n zx.meta matches 1.. run return 0

# ③ 发光(+超限: 缓慢Ⅱ / 标记 / 护甲韧性削减)
execute as @e[distance=..8,tag=zx.ss_q] run function fallendream:equipment/armor/spirit_sight/mark_one
tag @e[tag=zx.ss_q] remove zx.ss_q

# ④ 自身回魔: 基础 1 点 / 超限 每只 8 点
scoreboard players set #ss_gain zx.meta 1
execute if score #ss_ol zx.meta matches 1 run scoreboard players operation #ss_gain zx.meta = #ss_n zx.meta
execute if score #ss_ol zx.meta matches 1 run scoreboard players operation #ss_gain zx.meta *= #8 zx.meta
scoreboard players operation @s zx.regen_extra += #ss_gain zx.meta
function fallendream:equipment/armor/spirit_sight/gain
