# ============================================================
# sweetdream:upgrade/second —— 升级系统的每秒入口(挂在 sweetdream:lib/second)
# ------------------------------------------------------------
# 【为什么是每秒】盔甲升级是"穿着就一直在"的加成, 换装那一下需要改面板;
#   每秒回魔本身也是每秒性质。每秒跑一次 = 每刻的 1/20 开销。
# 【为什么先 execute as @a】从 lib/second 过来时是服务器身份、没有 @s。
# 【为什么备份公共输入口】下面要读写 manacore:in arg, 见 lib/in_bak。
# ============================================================

function sweetdream:lib/in_bak

execute as @a run function sweetdream:upgrade/armor_apply

function sweetdream:lib/in_restore
