# ============================================================
# sweetdream:equipment/armor/furnace_core/look_seg —— 炉心: 观测镜里的「燃灰」段
# ------------------------------------------------------------
# 【谁调用它】equipment/tool/look/render_go —— 在 layer 表**之前**调, 执行者 = 玩家本人
# 【★ 为什么从 layer 表里搬出来(2026-10-10) ★】
#   layer 表的 `max` 是**写死的常数**(表头注释: "上限是写死的常数, 不是计分项"),
#   而一行只能给一个上限 —— 炉心「燃灰」的上限**随超限变**: 基础 10 / 超限 12。
#   留在表里只能写死一个数: 写 10 则超限显示 "x/10"(用户 2026-10-10 反馈
#   "观测镜显示燃灰层数上限应该变, 现在还是 10"), 写 12 则基础版显示错。
#   所以按 render_go 里"装备专属文字型段"的口径把这一段搬出来, 由"身上这件是不是
#   超限版"现选 10 / 12 —— 和 furnace_core/{hit,passive} 里 `#fc_cap` 的 10/12 同口径。
#   ★ 表里那一行已删除, 别再加回去(会显示成两份燃灰)。
# 【★ 放在 layer_unroll 之前 = 保持"燃灰"仍在层数段最左 ★】
#   它和 layer_row 共用同一套分隔符协议(#ly_first), 谁先命中谁垫 "  ｜ "。
# 【★ 分隔符必须"先抄一份再清" ★】
#   mcfunction 没有 else: 直接写 "if(==1){垫｜;置0}" 再跟 "if(==0){垫·}" 的话,
#   第一条会把两个都垫上(见 layer_row 头注释)。
# 【显示条件(和 layer 表同一口径)】
#   ① 炉心在身上 / 在手上(zx:work eq.furnace_core, 由 debug/equip_scan 扫 6 格登记)
#   ② 燃灰层数非 0(没在积攒就不占位置)
# 【★ 必须先把分数建出来 ★】从没攒过燃灰时 zx.fc_ash **没有分数**, 这时 `matches 0`
#   会**直接失败**(不是当成 0) ⇒ 守卫放行 ⇒ 观测镜冒出个空的"燃灰"标签
#   (2026-10-05 幽灵段事故同款, 见 layer_row 头注释)。
# ============================================================

scoreboard players add @s zx.fc_ash 0
execute unless data storage zx:work eq.furnace_core run return 0
execute if score @s zx.fc_ash matches 0 run return 0

# ---- 超限判定: 炉心穿 / 拿在哪一格都算(和 render_go 扫 6 格登记 eq. 同一口径) ----
#   `ol` 只在"敲过超限"的物品上写(= 自己那件装备的 id), 基础版没有这个键。
scoreboard players set #fc_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["furnace_core"],ol:"furnace_core"}] run scoreboard players set #fc_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["furnace_core"],ol:"furnace_core"}] run scoreboard players set #fc_ol zx.meta 1
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["furnace_core"],ol:"furnace_core"}] run scoreboard players set #fc_ol zx.meta 1
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["furnace_core"],ol:"furnace_core"}] run scoreboard players set #fc_ol zx.meta 1
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["furnace_core"],ol:"furnace_core"}] run scoreboard players set #fc_ol zx.meta 1
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["furnace_core"],ol:"furnace_core"}] run scoreboard players set #fc_ol zx.meta 1

# ---- 分隔符(和 layer_row 同一套: 先抄一份再清) ----
scoreboard players operation #ly_was zx.meta = #ly_first zx.meta
scoreboard players set #ly_first zx.meta 0
execute if score #ly_was zx.meta matches 1 run data modify storage zx:look xline append value {"text":"  ｜ ","color":"dark_gray"}
execute if score #ly_was zx.meta matches 0 run data modify storage zx:look xline append value {"text":"  ·  ","color":"dark_gray"}

# ---- 标签 + 当前层数 + 上限(基础 10 / 超限 12) ----
data modify storage zx:look xline append value {"text":"燃灰 ","color":"gray"}
data modify storage zx:look xline append value {"score":{"name":"@s","objective":"zx.fc_ash"},"color":"yellow"}
execute if score #fc_ol zx.meta matches 0 run data modify storage zx:look xline append value {"text":"/10","color":"dark_gray"}
execute if score #fc_ol zx.meta matches 1 run data modify storage zx:look xline append value {"text":"/12","color":"dark_gray"}
