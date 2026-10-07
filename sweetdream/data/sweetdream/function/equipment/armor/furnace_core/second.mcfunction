# ============================================================
# sweetdream:equipment/armor/furnace_core/second —— 炉心的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【为什么先 execute as @a】事件是服务器身份、没有 @s, 后面每步都要玩家身份。
# 【为什么对全部玩家跑】三条加成都是差值账本, 脱下那一秒也要有人把数值减回去
#   (详见 passive 的头注释)。
# 【燃灰的"攒层"不在这里】那一下是"攻击燃烧中的生物"触发的, 由进度
#   sweetdream:equipment/armor/furnace_core_hit 调用 furnace_core/hit。
# ============================================================

# 【备份公共输入口】这套每秒逻辑要读写面板(攻击力 / 生命 / 魔力), 见 lib/in_bak
function sweetdream:lib/in_bak

execute as @a run function sweetdream:equipment/armor/furnace_core/passive

function sweetdream:lib/in_restore
