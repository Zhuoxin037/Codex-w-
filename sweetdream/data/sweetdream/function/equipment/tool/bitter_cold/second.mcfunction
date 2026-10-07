# ============================================================
# sweetdream:equipment/tool/bitter_cold/second —— 苦寒的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【它做的是"另一半"】文案两条:
#   ① "解除冻结状态后获得 5 秒缓慢Ⅲ和虚弱Ⅲ, 之后使其附加「渊海」"
#      —— 那是**一次性事件**, 挂在 lib/unfreeze_one 里(解冻那一刻就地广播);
#         不能靠每秒轮询检测(1 秒内的解冻会漏判, 且会锁相, 见 unfreeze_dim 的说明)。
#   ② "自身 5 格内有「渊海」效果的生物获得常态的缓慢Ⅱ"
#      —— "常态" = 条件满足期间一直续, 所以放这里每秒续一次。
# 【为什么先判副手再进 aura】不判的话每刻都在为不拿这件道具的玩家圈范围。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bitter_cold"]}] run function sweetdream:equipment/tool/bitter_cold/aura

function sweetdream:lib/in_restore
