# ============================================================
# sweetdream:equipment/armor/flesh_mill/second —— 血肉磨坊·每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second
# 【分批】passive 要 `api/mana/add` 改魔力, 所以用 lib/in_bak 夹住(见那个文件)。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/flesh_mill/passive

function sweetdream:lib/in_restore
