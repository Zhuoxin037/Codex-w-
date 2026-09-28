# ============================================================
# sweetdream:equipment/armor/external_power/second —— 体外供能装置的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上
# 【跟静脉泵那份一样】register 自己、然后逐个在线玩家处理。
# ============================================================

execute as @a run function sweetdream:equipment/armor/external_power/passive
