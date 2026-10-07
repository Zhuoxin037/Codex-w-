# ============================================================
# sweetdream:upgrade/api/fit_uncolor —— 无色石能不能消(宏 {x,y,z,...})
# ------------------------------------------------------------
# 【谁调用它】station/api/apply_go(st.kind = "uncolor")
# 【判据】副手装备的 up 列表非空(有升级可消)。类别不限 —— 什么装备敲过什么
#   都能消; 只动 up,**不碰超限(ol)**(无色石管升级, 不管超限)。
# 【出参】zx:out r {ok, reason:"empty"}; 另外把"要消的那条"(up 列表**最后一条**
#   = 最近敲入的, 玩家 2026-10-07 口径)的石头 id 抓到 zx:work uc.id ——
#   uncolor_go 靠它把"这条 + 它的全部前置"整条链还回去(uncolor_give 递归往上)。
# 【为什么抓"最后一条"用逐槽比分数】"最后一条"的槽位 = 条数-1, 是动态的;
#   静态命令读不了 up[变量] —— 用 #uc_i(每行写死槽号)和 #uc_last(条数-1)比
#   分数, 相等那行把 id 抄出来, 免宏。
# 【★ 比较符只有 = ★】原版计分板比较是 `=` / `<` / `<=` / `>` / `>=`,
#   **没有 `==`**。写成 `==` 是解析期错误 ⇒ "Whilst parsing command on line N:
#   错误的命令参数" ⇒ **整个函数加载失败**(无色石"右键完全没反应"的根因,
#   2026-10-07 踩到; check 规则 `scoreeq` 盯着)。
# ============================================================

data modify storage zx:out r set value {ok:0b,reason:"empty"}

# up 不存在 / 空列表 -> 没有可消的
execute unless data entity @s equipment.offhand.components."minecraft:custom_data".up[0] run return 0

# 条数 + "最后一条"的槽号
execute store result score #uc_sz zx.meta run data get entity @s equipment.offhand.components."minecraft:custom_data".up
scoreboard players operation #uc_last zx.meta = #uc_sz zx.meta
scoreboard players remove #uc_last zx.meta 1

# 抓最后一条的石头 id(槽号 == #uc_last 的那行命中)
scoreboard players set #uc_i zx.meta 0
execute if score #uc_i zx.meta = #uc_last zx.meta run data modify storage zx:work uc.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[0]
scoreboard players set #uc_i zx.meta 1
execute if score #uc_i zx.meta = #uc_last zx.meta run data modify storage zx:work uc.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[1]
scoreboard players set #uc_i zx.meta 2
execute if score #uc_i zx.meta = #uc_last zx.meta run data modify storage zx:work uc.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[2]
scoreboard players set #uc_i zx.meta 3
execute if score #uc_i zx.meta = #uc_last zx.meta run data modify storage zx:work uc.id set from entity @s equipment.offhand.components."minecraft:custom_data".up[3]

data modify storage zx:out r.ok set value 1b
