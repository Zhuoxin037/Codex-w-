# ============================================================
# internal/uuid/nibbles —— 把一个 32 位整数拆成 8 个半字节
# ------------------------------------------------------------
# 【输入】manacore:work a.value(整数)
# 【输出】manacore:work a.nib0 .. a.nib7(nib0 = 最高位半字节)
# 【为什么不用位运算】Minecraft 的 `scoreboard players operation` **不支持**
#   `>>=` / `&=` 这类位运算(只会报"无效的操作")。所以这里改用算术:
#       半字节 = ((t % 16) + 16) % 16       ← 负数也能得到 0..15
#       t      = (t - 半字节) / 16
#   重复 8 次, 依次取出最低 4 位; 第 8 次取到的就是最高位半字节。
# 【负数验证】value = -1 (即 0xFFFFFFFF): 每次都得到 15, 结果 "ffffffff" ✓
#            value = 1: 得到 nib0..nib6 = 0, nib7 = 1, 结果 "00000001" ✓
# 【常量】#16 = 16(由 core/boot 设置)
#
# 【★ 2026-10-10 事故(除零 ⇒ UUID 键退化)★】下面 7 处 `/=` 的除数原来是
#   `#16 manacore.math`, 但 boot 只设了 `scoreboard players set #16 manacore.meta 16`
#   ⇒ `manacore.math` 里的 #16 根本不存在(读到 0) ⇒ **整数除以零** ⇒ 该条
#   `scoreboard players operation` 静默失败、#t 不更新 ⇒ 8 次拆半字节里只有
#   第 1 次(最低位)是对的, 其余 7 个恒为 0。
#   后果: 32 位 hex 退化成"**四个整数各自的低 4 位**"(如 0000000f000000050000000000000007),
#   玩家键大面积冲突(两个玩家只要低 4 位相同就共键 ⇒ 互相覆盖数据)。
#   ★ 修法: `/=` 的除数与上面 `%=`/`+=` 一样用 manacore.meta。
#   ★ 教训: **跨计分板引用常量前, 先确认那个常量在"目标计分项"里真的被设过** ——
#          读不到的分数是 0, 不报错。守门已加 nibbles 形态锁。
# ============================================================
execute store result score #t manacore.math run data get storage manacore:work a.value

scoreboard players operation #b0 manacore.math = #t manacore.math
scoreboard players operation #b0 manacore.math %= #16 manacore.meta
scoreboard players operation #b0 manacore.math += #16 manacore.meta
scoreboard players operation #b0 manacore.math %= #16 manacore.meta
scoreboard players operation #t manacore.math -= #b0 manacore.math
scoreboard players operation #t manacore.math /= #16 manacore.meta

scoreboard players operation #b1 manacore.math = #t manacore.math
scoreboard players operation #b1 manacore.math %= #16 manacore.meta
scoreboard players operation #b1 manacore.math += #16 manacore.meta
scoreboard players operation #b1 manacore.math %= #16 manacore.meta
scoreboard players operation #t manacore.math -= #b1 manacore.math
scoreboard players operation #t manacore.math /= #16 manacore.meta

scoreboard players operation #b2 manacore.math = #t manacore.math
scoreboard players operation #b2 manacore.math %= #16 manacore.meta
scoreboard players operation #b2 manacore.math += #16 manacore.meta
scoreboard players operation #b2 manacore.math %= #16 manacore.meta
scoreboard players operation #t manacore.math -= #b2 manacore.math
scoreboard players operation #t manacore.math /= #16 manacore.meta

scoreboard players operation #b3 manacore.math = #t manacore.math
scoreboard players operation #b3 manacore.math %= #16 manacore.meta
scoreboard players operation #b3 manacore.math += #16 manacore.meta
scoreboard players operation #b3 manacore.math %= #16 manacore.meta
scoreboard players operation #t manacore.math -= #b3 manacore.math
scoreboard players operation #t manacore.math /= #16 manacore.meta

scoreboard players operation #b4 manacore.math = #t manacore.math
scoreboard players operation #b4 manacore.math %= #16 manacore.meta
scoreboard players operation #b4 manacore.math += #16 manacore.meta
scoreboard players operation #b4 manacore.math %= #16 manacore.meta
scoreboard players operation #t manacore.math -= #b4 manacore.math
scoreboard players operation #t manacore.math /= #16 manacore.meta

scoreboard players operation #b5 manacore.math = #t manacore.math
scoreboard players operation #b5 manacore.math %= #16 manacore.meta
scoreboard players operation #b5 manacore.math += #16 manacore.meta
scoreboard players operation #b5 manacore.math %= #16 manacore.meta
scoreboard players operation #t manacore.math -= #b5 manacore.math
scoreboard players operation #t manacore.math /= #16 manacore.meta

scoreboard players operation #b6 manacore.math = #t manacore.math
scoreboard players operation #b6 manacore.math %= #16 manacore.meta
scoreboard players operation #b6 manacore.math += #16 manacore.meta
scoreboard players operation #b6 manacore.math %= #16 manacore.meta
scoreboard players operation #t manacore.math -= #b6 manacore.math
scoreboard players operation #t manacore.math /= #16 manacore.meta

scoreboard players operation #b7 manacore.math = #t manacore.math
scoreboard players operation #b7 manacore.math %= #16 manacore.meta
scoreboard players operation #b7 manacore.math += #16 manacore.meta
scoreboard players operation #b7 manacore.math %= #16 manacore.meta

execute store result storage manacore:work a.nib0 int 1 run scoreboard players get #b7 manacore.math
execute store result storage manacore:work a.nib1 int 1 run scoreboard players get #b6 manacore.math
execute store result storage manacore:work a.nib2 int 1 run scoreboard players get #b5 manacore.math
execute store result storage manacore:work a.nib3 int 1 run scoreboard players get #b4 manacore.math
execute store result storage manacore:work a.nib4 int 1 run scoreboard players get #b3 manacore.math
execute store result storage manacore:work a.nib5 int 1 run scoreboard players get #b2 manacore.math
execute store result storage manacore:work a.nib6 int 1 run scoreboard players get #b1 manacore.math
execute store result storage manacore:work a.nib7 int 1 run scoreboard players get #b0 manacore.math
