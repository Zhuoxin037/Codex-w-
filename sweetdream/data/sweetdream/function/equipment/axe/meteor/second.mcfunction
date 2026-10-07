# ============================================================
# sweetdream:equipment/axe/meteor/second —— 陨星的每秒入口
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second
# 【备份公共输入口】见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

execute as @a[scores={zx.mt_on=1..}] run function sweetdream:equipment/axe/meteor/state_tick

function sweetdream:lib/in_restore
