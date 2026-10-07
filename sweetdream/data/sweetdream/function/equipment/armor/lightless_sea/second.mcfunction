# ============================================================
# sweetdream:equipment/armor/lightless_sea/second —— 无光海的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【内容】
#   · 每个玩家: 被动(魔力账本 / 虚弱Ⅲ / 回魔 / 攻击力账本) —— 见 passive
#   · 每个"暗潮": tide_tick(常态缓慢Ⅱ + 套装伤害)
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/lightless_sea/passive

execute as @e[tag=zx.ls_tide] at @s run function sweetdream:equipment/armor/lightless_sea/tide_tick

function sweetdream:lib/in_restore
