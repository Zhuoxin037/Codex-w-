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

# 冷却剂 / 魔力沸涌(2026-10-07): 冷却缩减属性 + 长冷却/低魔力的额外减冷却。
# 也放在 in_bak/in_restore 里 —— 它要调 manacore 的 cooldown_reduction_set
# 与 mana/get(都会写公共输入口 manacore:in arg)。
execute as @a run function sweetdream:upgrade/api/cd_tick

function sweetdream:lib/in_restore

# 神经衰弱石(2026-10-12): 攻击速度是"持续型原版属性", 每秒按**主手**对一次账。
# 放在 in_restore 之后 —— 它不碰 manacore:in arg(只挂属性), 不需要备份窗口。
execute as @a run function sweetdream:upgrade/held_apply
