# ------------------------------------------------------------
# internal/cooldown/reset_all —— 清空该玩家全部冷却
# 【宏参数】manacore:work.a {uuid}
# 【做法】把 cooldowns 整体置空 {}。
# 【用途】复活、进入新副本、GM 指令。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)".cooldowns run data modify storage manacore:players "$(uuid)".cooldowns set value {}
