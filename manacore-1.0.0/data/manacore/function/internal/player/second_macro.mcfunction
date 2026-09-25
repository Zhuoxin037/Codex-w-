# ------------------------------------------------------------
# internal/player/second_macro —— 玩家的"每秒 tick"
# 【宏参数】manacore:work.entry {uuid,u0..u3,slot}
# 【当前包含】
#   mana/regen_driver    : 魔力恢复(基础+修正 -> x倍率 -> 禁止判定 -> 上限夹取)
#   formation/tick_driver: 术阵到期移除
# 【想扩展】你自己的"每秒 buff / 状态"逻辑最适合挂在这里, 或者更推荐挂到
#         #manacore:event/second 标签(那样不需要改前置包)。
# ------------------------------------------------------------
function manacore:internal/mana/regen_driver with storage manacore:work entry
function manacore:internal/formation/tick_driver with storage manacore:work entry
