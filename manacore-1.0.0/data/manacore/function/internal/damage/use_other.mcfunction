# ------------------------------------------------------------
# internal/damage/use_other —— 其他倍率通道的基数: other_base 传 -1 时用当前魔力
# 【宏参数】manacore:work.a {uuid}
# 【写入】#base_o(manacore.math, x1000)
# 【为什么默认是当前魔力】"既不是最大魔力、也不是攻击力"的那一类技能,
#   包内最常见的口径就是"自身当前魔力值 × N"(深海回响 / 挽歌 / 超负荷 / 风行普攻)。
#   把默认基数设成当前魔力, 这些技能就只写一个 other_mul 即可;
#   真要用别的基数, 直接给 other_base 一个 >= 0 的数覆盖。
# ------------------------------------------------------------
$execute store result score #base_o manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
