# ============================================================
# sweetdream:tg/api/held —— 读取**执行者主手物品**的标签列表
# ------------------------------------------------------------
# 【无入参】
# 【出参】storage zx:out tags = ["标签",…](主手物品的 custom_data.tags; 没有则为空表)
# 【用法】地图想知道"玩家手里这件装备是什么类型":
#     function sweetdream:tg/api/held
#     data get storage zx:out tags
#   (execute as <玩家> run function ...; 调用者是谁就查谁的)
# 【也可直接用谓词(不经过本接口)】
#     if items entity @s weapon.mainhand *[minecraft:custom_data~{tags:["dash"]}]
#   —— 谓词的列表匹配是"包含"语义, 上面这句 = "主手含 dash"。
# ============================================================
data modify storage zx:out tags set value []
execute if data entity @s SelectedItem.components."minecraft:custom_data".tags run data modify storage zx:out tags set from entity @s SelectedItem.components."minecraft:custom_data".tags
