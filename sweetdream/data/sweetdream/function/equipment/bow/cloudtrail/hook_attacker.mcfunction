# ============================================================
# sweetdream:equipment/bow/cloudtrail/hook_attacker —— 附魔回调: 记下射手
# ------------------------------------------------------------
# 【谁调它】附魔 sweetdream:cloudtrail 的 post_attack, affected = attacker。
# 【执行者】射手(玩家); 由 hook_victim / apply 靠着 zx.ct_pl 找回射手。
# ============================================================

tag @e[tag=zx.ct_pl,distance=0..] remove zx.ct_pl
tag @s add zx.ct_pl
