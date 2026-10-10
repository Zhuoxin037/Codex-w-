# ============================================================
# sweetdream:upgrade/api/uncolor_go —— 无色石: 删掉最近敲入的升级
# ------------------------------------------------------------
# 【谁调用它】station/api/apply_go(st.kind = "uncolor"; fit_uncolor 已通过)
# 【做法】重建 up 列表: 保留槽号 < #uc_last 的条目(和敲入的 up_rebuild 同思路,
#   但"去留"判的是**槽号**而不是系列名, 分数就能判, 不用宏链), 整体写回;
#   然后把"被消的那条 + 它的全部前置"还给玩家(uncolor_give 递归, 见下)。
# 【★ 返还整条链(2026-10-07 二次改) ★】消 Ω 还 **α+β+Ω 三颗**:
#   敲 β 的前提是先敲过 α(替换制下 α 已被 β 顶掉、不在物品上了), 所以消掉 β 时
#   玩家实际损失的是 α+β 两颗。uncolor_give 沿定义表 req 链递归往上, 每级还一颗。
# 【kept 键集是干什么的】老物品(旧规则敲的)同系可能残留两条 —— 消掉最后一条后,
#   留下的那条还在物品上, 再还一颗就**凭空多发**了。所以重建时把"留在物品上的 id"
#   记进 zx:work kept."<id>", uncolor_give 跳过它们。
# 【为什么属性不用手动重算】护甲/生命/冷却那些账都是 upgrade/second 每秒按
#   物品身上的 up 现算的 —— 列表一变, 下一秒自动回到正确值。
# 【改的是哪一件】中转架 @e[tag=zx.st_tmp,limit=1] 主手上那一件
#   (2026-10-08 前是"工作台箱子 0,-59,2"那一格 —— 那个箱子已经废掉了)。
# 【执行者】玩家
# ============================================================

# 保留 index < last 的条目(0..3 逐槽判; 没有/超界的格子自然跳过)
# ★ 每个保留项都走 uncolor_keep: ① 记进 kept 键集 ② 搬进 newlist ★
data remove storage zx:work newlist
data modify storage zx:work newlist set value []
data remove storage zx:work kept
# #uc_d = uncolor_give 的递归深度计数(它自己会 +1, 这里归零)
scoreboard players set #uc_d zx.meta 0
scoreboard players set #uc_i zx.meta 0
execute if score #uc_i zx.meta < #uc_last zx.meta run data modify storage zx:work uc.keep set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0]
execute if score #uc_i zx.meta < #uc_last zx.meta run function sweetdream:upgrade/api/uncolor_keep with storage zx:work uc
scoreboard players set #uc_i zx.meta 1
execute if score #uc_i zx.meta < #uc_last zx.meta run data modify storage zx:work uc.keep set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[1]
execute if score #uc_i zx.meta < #uc_last zx.meta run function sweetdream:upgrade/api/uncolor_keep with storage zx:work uc
scoreboard players set #uc_i zx.meta 2
execute if score #uc_i zx.meta < #uc_last zx.meta run data modify storage zx:work uc.keep set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[2]
execute if score #uc_i zx.meta < #uc_last zx.meta run function sweetdream:upgrade/api/uncolor_keep with storage zx:work uc
scoreboard players set #uc_i zx.meta 3
execute if score #uc_i zx.meta < #uc_last zx.meta run data modify storage zx:work uc.keep set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[3]
execute if score #uc_i zx.meta < #uc_last zx.meta run function sweetdream:upgrade/api/uncolor_keep with storage zx:work uc

# 写回(消到 0 条就是空列表 —— data get 空表 = 0 条, 后面的判据都成立)
data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up set from storage zx:work newlist

# 把"被消的那条 + 它的全部前置"还给玩家(zx:work uc.id = 被消那条, 递归游标走 ucnext)
function sweetdream:upgrade/api/uncolor_give with storage zx:work uc
