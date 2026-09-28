# ============================================================
# sweetdream:equipment/armor/external_power/second —— 体外供能装置的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上
# 【跟静脉泵那份一样】register 自己、然后逐个在线玩家处理。
# ============================================================

# 【备份公共输入口】下面这套每秒逻辑会写 manacore:in arg(读魔力要用它),
#   不还回去的话, 你在聊天栏手填的参数一秒就被冲掉 —— 见 lib/in_bak。
function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/external_power/passive

function sweetdream:lib/in_restore
