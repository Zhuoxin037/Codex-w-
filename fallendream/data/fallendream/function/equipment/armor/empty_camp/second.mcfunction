# ============================================================
# fallendream:equipment/armor/empty_camp/second —— 「空营」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +140（armor_mana 登记）。自身 8 格内每有 1 个敌对生物，护甲值 +1、
#   护甲韧性 +0.5（最多 6 层）。8 格内没有敌对生物时，每秒恢复 3 点魔力值。
# 【★ 敌对 = type=!#fallendream:no_damage 且不是玩家 ★】包内 `no_damage` 排除 marker /
#   法球 / 领域；再排除玩家 —— "敌对生物"不含队友（多人同场时否则会互相顶层数）。
#   ★ 与"全部生物"类技能（神裁/踏空）**相反**：那些按包内口径包含玩家。
# 【★ 数数量 ★】`as @e[...] run scoreboard players add` —— 每只加 1，这是 mcfunctions
#   里唯一可靠的计数写法（没有 count 命令）。
# 【★ 换档先摘后挂 ★】同 id modifier 重复 add 会失败；档位没变就一条都不发。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run function fallendream:equipment/armor/empty_camp/off
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run return 0

# ①.5 分档：超限·空营（2026-11-22）
#   满层额外抗性Ⅱ（每秒给 2 秒，离开满层后最多再挂 2 秒自然消退，不用 effect clear
#   去抹 —— 那会把别处给的抗性一起清掉）。
scoreboard players set #ec_ol zx.meta 0
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"],ol:"empty_camp"}] run scoreboard players set #ec_ol zx.meta 1

# ① 数 8 格内敌对，夹到 6
scoreboard players set #ec_n zx.meta 0
execute as @e[type=#fallendream:hostile,distance=..8] run scoreboard players add #ec_n zx.meta 1
scoreboard players set #ec_6 zx.meta 6
execute if score #ec_n zx.meta > #ec_6 zx.meta run scoreboard players set #ec_n zx.meta 6

# ② 换档（护甲 = n / 韧性 = 0.5n）
execute unless score #ec_n zx.meta = @s zx.ec_a run function fallendream:equipment/armor/empty_camp/attr_arm
execute unless score #ec_n zx.meta = @s zx.ec_t run function fallendream:equipment/armor/empty_camp/attr_tou

# ②.5 超限满层：抗性提升Ⅱ（每秒重给 2 秒，天然不残留）
execute if score #ec_ol zx.meta matches 1 if score #ec_n zx.meta matches 6 run effect give @s minecraft:resistance 2 1 true

# ③ 有敌对就不回魔
execute if score #ec_n zx.meta matches 1.. run return 0

# ④ 每秒回魔：基础 3 点 / 超限 1% 上限魔力
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:3.0}
execute if score #ec_ol zx.meta matches 1 run function fallendream:equipment/armor/empty_camp/ol_regen
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ⑤ 超限且无敌对：自身套装效果冷却每秒额外 -1 秒
execute if score #ec_ol zx.meta matches 1 run function fallendream:equipment/armor/empty_camp/set_cd_tick
