# ============================================================
# sweetdream:overlimit/api/name_seed —— 把物品**改名**(宏 {ol})
# ------------------------------------------------------------
# 【谁调用它】station/api/lore_refresh 的 ② —— 和 lore_seed 一起, 只在敲过超限时走。
# 【改的是哪一件】中转架 @e[tag=zx.st_tmp,limit=1] 主手上那一件
#   (2026-10-08 前是"工作台箱子 0,-59,2"那一格 —— 那个箱子已经废掉了)。
# 【为什么】光换描述、名字还叫「流光」的话, 拿在手上跟原来那把没区别 ——
#   玩家要一眼看出"这把已经是超限版了"。所以超限同时把 item_name 换成
#   oldef.<ol>.name(定义表里那段就是完整的文本组件, 直接整段拷, 不走宏)。
# 【为什么用 item_name 不是 custom_name】give 出去的时候名字就是写在这个组件上的
#   (见 equipment/*/give), 这里跟着同一个组件改, 才不会出现两个名字打架。
# 【★ 没有 name 的兜底 ★】万一某条定义忘了写 name, 就**不动名字**(保持原名),
#   不会把物品变成"没有名字"。check.py 有专门的规则盯着这件事。
# ============================================================

$execute if data storage zx:config oldef."$(ol)".name run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:item_name" set from storage zx:config oldef."$(ol)".name
