# ============================================================
# sweetdream:equipment/sword/deepsea_echo/second —— 被动技能的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【跟护甲那套一模一样】自己注册自己: 以后加新的装备,
#   在 event/second.json 的 values 里多加一条自己的 second 就行。
# ============================================================

# 【备份公共输入口】理由见 lib/in_bak
function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/sword/deepsea_echo/passive

function sweetdream:lib/in_restore
