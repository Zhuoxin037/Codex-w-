# ============================================================
# sweetdream:core/tick —— 每游戏刻执行
# ------------------------------------------------------------
# 【谁调用它】data/minecraft/tags/function/tick.json
# 【目前只做一件事】给"开着数值面板"的玩家刷新动作栏。
#   筛选直接用标签 @a[tag=test_look_on], 没开面板的玩家完全不参与, 开销可忽略。
# 【以后加东西】每刻的逻辑写这里; 每秒的逻辑建议挂到 #manacore:event/second。
# ============================================================

execute as @a[tag=test_look_on] run function sweetdream:equipment/look/render
