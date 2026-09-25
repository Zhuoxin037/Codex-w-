# ============================================================
# internal/mana/regen_driver —— 每秒魔力恢复主流程
# ------------------------------------------------------------
# 【宏参数】manacore:work.entry {uuid}
# 【公式】本次恢复量 = (基础恢复 mana_regen + 各来源修正之和) x 恢复倍率
#         然后依次套用: 禁止恢复标记 -> 恢复封锁到期时间 -> 上限夹取
# 【执行顺序】
#   ① regen_base        : 把玩家面板上的 base 每秒恢复读进 #regen
#   ② 8 次 regen_one    : 依次处理 8 个修正槽位(可堆叠, 含临时修正的过期清理)
#   ③ regen_apply       : 抛 mana_regen 事件 -> 乘倍率 -> 判禁止 -> 写回
# 【为什么固定 8 个槽位】Minecraft 无法遍历"任意键名的复合标签",
#         所以所有可堆叠列表都用固定长度的槽位数组 + 展开式循环。
#         想扩容就同步改这里、mod_find_driver 与默认模板的长度。
# 【调用方】internal/player/second_macro(每个在线玩家每秒一次)
# ============================================================
function manacore:internal/mana/regen_base with storage manacore:work entry
data modify storage manacore:work entry.i set value 0
function manacore:internal/mana/regen_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 1
function manacore:internal/mana/regen_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 2
function manacore:internal/mana/regen_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 3
function manacore:internal/mana/regen_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 4
function manacore:internal/mana/regen_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 5
function manacore:internal/mana/regen_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 6
function manacore:internal/mana/regen_one with storage manacore:work entry
data modify storage manacore:work entry.i set value 7
function manacore:internal/mana/regen_one with storage manacore:work entry
function manacore:internal/mana/regen_apply with storage manacore:work entry
